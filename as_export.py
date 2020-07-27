#!/usr/bin/env pythonpython

import os, requests, json, sys, time, pickle, logging, ConfigParser, re, subprocess, random, psutil, pdb
from lxml import etree
from requests_toolbelt import exceptions
from requests_toolbelt.downloadutils import stream

# local config file, containing variables
configFilePath = 'local_settings.cfg'
config = ConfigParser.ConfigParser()
config.read(configFilePath)
# URL parameters dictionary, used to manage common URL patterns
dictionary = {'baseURL': config.get('ArchivesSpace', 'baseURL'), 'repository':config.get('ArchivesSpace', 'repository'), 'user': config.get('ArchivesSpace', 'user'), 'password': config.get('ArchivesSpace', 'password')}
baseURL = '{baseURL}'.format(**dictionary)
repositoryBaseURL = '{baseURL}/repositories/{repository}/'.format(**dictionary)
# Location of Pickle file which contains last export time
lastExportFilepath = config.get('LastExport', 'filepath')
# EAD Export options
exportUnpublished = config.get('EADexport', 'exportUnpublished')
exportDaos = config.get('EADexport', 'exportDaos')
exportNumbered = config.get('EADexport', 'exportNumbered')
# ResourceID lists (to be populated by ids of exported or deleted records)
resourceExportList = []
resourceDeleteList = []
doExportList = []
doDeleteList = []
# Logging configuration
logging.basicConfig(filename=config.get('Logging', 'filename'),format=config.get('Logging', 'format', 1), datefmt=config.get('Logging', 'datefmt', 1), level=config.get('Logging', 'level', 0))
# Sets logging of requests to WARNING to avoid unneccessary info
logging.getLogger("requests").setLevel(logging.DEBUG)

# export destinations, os.path.sep makes these absolute URLs
dataDestination = config.get('Destinations', 'dataDestination')
EADdestination = config.get('Destinations', 'EADdestination')

# file path to record process id
pidfilepath = 'daemon.pid'

# check to see if process is already running
def checkPid(pidfilepath):
    currentPid = str(os.getpid())

    if os.path.isfile(pidfilepath):
        pidfile = open(pidfilepath, "r")
        for line in pidfile:
            pid=int(line.strip())
        if psutil.pid_exists(pid):
            logging.error('Process already running, exiting')
            sys.exit()
        else:
            file(pidfilepath, 'w').write(currentPid)
    else:
        file(pidfilepath, 'w').write(currentPid)

def makeDestinations():
    destinations = [EADdestination]
    for d in destinations:
        if not os.path.exists(d):
            os.makedirs(d)

# authenticates the session
def authenticate():
    try:
        auth = requests.post('{baseURL}/users/{user}/login?password={password}&expiring=false'.format(**dictionary)).json()
        token = {'X-ArchivesSpace-Session':auth["session"]}
        return token
    except requests.exceptions.RequestException as e:
        print 'Authentication failed! Make sure the baseURL setting in %s is correct and that your ArchivesSpace instance is running.' % configFilePath
        print e
        sys.exit(1)
    except KeyError:
        print 'Authentication failed! It looks like you entered the wrong password. Please check the information in %s.' % configFilePath
        sys.exit(1)

# logs out non-expiring session (not yet in AS core, so commented out)
def logout():
    requests.post('{baseURL}/logout'.format(**dictionary))
    logging.info('You have been logged out of your session')

# gets time of last export
def readTime():
    # last export time in Unix epoch time, for example 1439563523
    if os.path.isfile(lastExportFilepath):
        with open(lastExportFilepath, 'rb') as pickle_handle:
            lastExport = str(pickle.load(pickle_handle))
    else:
        lastExport = 0
    return lastExport

# store the current time in Unix epoch time, for example 1439563523
def updateTime(exportStartTime):
    with open(lastExportFilepath, 'wb') as pickle_handle:
        pickle.dump(exportStartTime, pickle_handle)
        logging.info('Last export time updated to ' + str(exportStartTime))

# formats XML files
def prettyPrintXml(filePath, resourceID, headers):
    assert filePath is not None
    parser = etree.XMLParser(resolve_entities=False, strip_cdata=False, remove_blank_text=True)
    try:
        etree.parse(filePath, parser)
        if 'LI' in resourceID:
            EADtoMODS(resourceID, filePath, headers)
            removeFile(resourceID, EADdestination)
        else:
            document = etree.parse(filePath, parser)
            document.write(filePath, pretty_print=True, encoding='utf-8')
    except:
        logging.warning('%s is invalid and will be removed', resourceID)
        removeFile(resourceID, EADdestination)

# Exports EAD file
def exportEAD(resourceID, identifier, headers):
    if not os.path.exists(os.path.join(EADdestination,resourceID)):
        os.makedirs(os.path.join(EADdestination,resourceID))
    try:
        with open(os.path.join(EADdestination,resourceID,resourceID+'.xml'), 'wb') as fd:
            ead = requests.get(repositoryBaseURL+'resource_descriptions/'+str(identifier)+'.xml?include_unpublished={exportUnpublished}&include_daos={exportDaos}'.format(exportUnpublished=exportUnpublished, exportDaos=exportDaos), headers=headers, stream=True)
            filename = stream.stream_response_to_file(ead, path=fd)
            fd.close
            logging.info('%s.xml exported to %s', resourceID, os.path.join(EADdestination,resourceID))
            resourceExportList.append(resourceID)
    except exceptions.StreamingError as e:
        logging.warning(e.message)
    #validate here
    prettyPrintXml(os.path.join(EADdestination,resourceID+'.xml'), resourceID, headers)

# Deletes EAD file if it exists
def removeFile(identifier, destination):
    if os.path.isfile(os.path.join(destination,identifier+'.xml')):
        os.remove(os.path.join(destination,identifier+'.xml'))
        logging.info('%s deleted from %s/%s', identifier, destination, identifier)
        resourceDeleteList.append(identifier)
    else:
        logging.info('%s does not already exist, no need to delete', identifier)

def handleResource(resource, headers):
    resourceID = resource["id_0"]+resource["id_1"]
    identifier = re.split('^/repositories/[1-9]*/resources/',resource["uri"])[1]
    if resource["publish"]:
        exportEAD(resourceID, identifier, headers)

def handleDigitalObject(digital_object, d, headers):
    doID = digital_object["digital_object_id"]
    try:
        digital_object["publish"]
    except:
        removeFile(doID)

def handleAssociatedDigitalObject(digital_object, resourceId, d, headers):
    doID = digital_object["digital_object_id"]
    try:
        digital_object["publish"]
        component = (requests.get(baseURL + digital_object["linked_instances"][0]["ref"], headers=headers)).json()
        if component["jsonmodel_type"] == 'resource':
            resourceRef = digital_object["linked_instances"][0]["ref"]
        else:
            resourceRef = component["resource"]["ref"]
        resource = resource = (requests.get(baseURL + resourceRef, headers=headers)).json()
    except:
        removeFile(doID)



def describe_resource(resource):
    return "%s:%s %s" % (resource['id_0'].encode('utf-8'), resource['id_1'].encode('utf-8'), resource['finding_aid_title'].encode('utf-8'))
        
#Looks for all resource records starting with a given prefix
def findAllLibraryResources(headers, prefix):
    resourceIds = requests.get(repositoryBaseURL+'resources?all_ids=true', headers=headers)
    logging.info('*** Getting a list of all resources ***')
    for r in resourceIds.json():
        resource = (requests.get(repositoryBaseURL+'resources/' + str(r), headers=headers)).json()
        if prefix in resource["id_0"]:
            print("    %s" % describe_resource(resource))
            handleResource(resource, headers)

# Looks for updated resources
def findUpdatedResources(lastExport, headers):
    print("***")
    print("Updated resources")
    resourceIds = requests.get(repositoryBaseURL+'resources?all_ids=true&modified_since='+str(lastExport), headers=headers)
    logging.info('*** Checking updated resources ***')
    for r in resourceIds.json():
        resource = (requests.get(repositoryBaseURL+'resources/' + str(r), headers=headers)).json()
        print(describe_resource(resource))
        handleResource(resource, headers)

def findUpdatedObjects(lastExport, headers):
    print("***")
    print("Updated objects")
    resources_dealt_with = []
    archival_objects = requests.get(repositoryBaseURL+'archival_objects?all_ids=true&modified_since='+str(lastExport), headers=headers)
    logging.info('*** Checking updated archival objects ***')
    for a in archival_objects.json():
        archival_object = requests.get(repositoryBaseURL+'archival_objects/'+str(a), headers=headers).json()
        resource = (requests.get(baseURL+archival_object["resource"]["ref"], headers=headers)).json()
        resource_reference = archival_object["resource"]["ref"]
        if not resource["id_0"] in resourceExportList and not resource["id_0"] in resourceDeleteList and not resource_reference in resources_dealt_with:
            print(describe_resource(resource))
            handleResource(resource, headers)
            resources_dealt_with.append(resource_reference)
            
# Looks for updated digital objects
def findUpdatedDigitalObjects(lastExport, headers):
    print("***")
    print("Updated digital objects")
    doIds = requests.get(repositoryBaseURL+'digital_objects?all_ids=true&modified_since='.format(**dictionary)+str(lastExport), headers=headers)
    logging.info('*** Checking updated digital objects ***')
    for d in doIds.json():
        digital_object = (requests.get(repositoryBaseURL+'digital_objects/' + str(d), headers=headers)).json()
        print digital_object['title']
        handleDigitalObject(digital_object, d, headers)

def main():
    print("Attempting full export.")
    logging.info('=========================================')
    logging.info('*** Export started ***')
    exportStartTime = int(time.time())
    lastExport = readTime()
    headers = authenticate()
    findUpdatedResources(lastExport, headers)
    findUpdatedObjects(lastExport, headers)
    findUpdatedDigitalObjects(lastExport, headers)
    logging.info('*** Export completed ***')
    updateTime(exportStartTime)


print("Starting")
checkPid(pidfilepath)
makeDestinations()
if len(sys.argv) >= 2:
    argument = sys.argv[1]
    if argument == '--update_time':
        logging.info('=========================================')
        exportStartTime = int(time.time())
        updateTime(exportStartTime)
    elif argument == '--prefix':
        logging.info('=========================================')
        logging.info('*** Export records started ***')
        headers = authenticate()
        prefixes = sys.argv[2:]
        for prefix in prefixes:
            logging.info("         Exporting records starting in %s" % prefix)
            findAllLibraryResources(headers, prefix)
        if len(resourceExportList) > 0 or len(resourceDeleteList) > 0:
          logging.info('*** Export completed ***')
else:
    main()
os.unlink(pidfilepath)
logout()
print("Done")
