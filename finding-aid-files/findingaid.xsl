<?xml version="1.0" encoding="UTF-8"?>
<!-- this is a modified version of a stylesheet written by Sean Watkins https://github.com/seanlw/ead-xslt modified by Sarah Newhouse & Dan Sanford, Science History Institute 2017-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ead="urn:isbn:1-931666-22-9"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <xsl:output method="html"
              encoding="UTF-8"
              indent="yes" />
  <xsl:template match="/*">
    <html>
       <head>
	   <!-- will not work in production, need to be updated with directories-->
        <title><xsl:value-of select="ead:archdesc/ead:did/ead:unittitle" /></title>
        <link rel="icon" type="../image/png" href="../img/favicon.ico" />
        <link rel="stylesheet" href="website-files/css/font-awesome.min.css" />
        <link rel="stylesheet" href="website-filescss/bootstrap.css" />
        <link rel="stylesheet" href="website-filescss/findingaid.css" />
        <link rel="stylesheet" href="website-filescss/uh-webfonts.css" />
		<!--<link rel="stylesheet" href="../css/footer.scss"/>-->
        <script src="website-filesjs/jquery-1.12.3.min.js"></script>
        <script src="website-filesjs/bootstrap.min.js"></script>
        <script src="website-filesjs/findingaid.js"></script>
      </head>
      <body>
          <div class="header">
		   <a href="https://www.sciencehistory.org/othmer-library">
			  <div class="topLogo">
				<img alt="Science History Institute and Othmer Library logos" src="website-files/img/library_header.png"/>
				</div>
              </a>
        </div>
        <div class="container-fluid">
          <div class="row">
            <div align="left" class="col-md-3">
              <div id="sidebar-menu" class="list-group">
                <a href="#overview" class="list-group-item">Overview</a>
				<a href="#bioghist" class="list-group-item">Background</a>
                <a href="#scope" class="list-group-item">Scope and Contents</a>
                <a href="#subjects" class="list-group-item">Subjects and Keywords</a>
                <a href="#administrative" class="list-group-item">Administrative Information</a>
                <a href="#listings" class="list-group-item">Collection Inventory</a>
				<a href="http://othmerlib.sciencehistory.org/" target="_blank" class="list-group-item">Search the Library Catalog</a>
              </div>
            </div>
            <div class="col-md-9">
              <!-- OVERVIEW -->
              <xsl:apply-templates select="ead:archdesc/ead:did" />
			 <!-- BIOGHIST-->
			 <xsl:apply-templates select="ead:archdesc/ead:bioghist"/>
              <!-- SCOPE AND CONTENTS -->
              <xsl:apply-templates select="ead:archdesc/ead:scopecontent" />
              <!-- TERMS AND ADMINISTRATIVE INFORMATION -->
              <xsl:apply-templates select="ead:archdesc" />
              <!-- BOX/FOLDER LISTING -->
              <xsl:apply-templates select="ead:archdesc/ead:dsc" />
            </div>
          </div>
        </div>
		<div class="container-fluid">
		<div class="footer"><p>© 2018 <a href="https://www.sciencehistory.org/othmer-library">Othmer Library of Chemical History</a> | <a href="https://www.sciencehistory.org/staff-directory">Contacts</a></p><p><a href="https://www.sciencehistory.org/">Science History Institute</a></p></div>
		</div>
      </body>
    </html>
  </xsl:template>
  
  <!-- OVERVIEW -->
  <xsl:template match="ead:archdesc/ead:did">
    <h1><xsl:value-of select="ead:unittitle" />, <xsl:value-of select="ead:unitdate" /></h1>
    <div id="overview" class="panel panel-info">
      <div class="panel-heading">
        <h2 class="panel-title">Overview</h2>
      </div>
      <div class="panel-body">
        <p><span class="bold">Collection Name: </span><xsl:value-of select="ead:unittitle" /></p>
        <p><span class="bold">Collection Number: </span><xsl:value-of select="ead:unitid" /></p>
        <p><span class="bold">Primary Creator(s): </span>
		<xsl:for-each select="ead:origination">
            <xsl:value-of select="." />
            <xsl:if test="position() &lt; last()">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:for-each></p>
        <p><span class="bold">Collection Size: </span><xsl:value-of select=".//ead:extent" /></p>
        <p><span class="bold">Abstract: </span>
		<xsl:copy-of select="ead:abstract"/></p>
		<p><span class="bold">Forms of Material: </span>
          <xsl:for-each select="../ead:controlaccess/ead:genreform">
            <xsl:value-of select="." />
            <xsl:if test="position() &lt; last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </p>
        <p><span class="bold">Languages: </span>
          <xsl:for-each select="ead:langmaterial">
            <xsl:value-of select="." />
            <xsl:if test="position() &lt; last()">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </p>
		<p><span class="bold">Access to Physical Collection: </span>To make an appointment to view items from this collection in the Othmer Library reading room, please fill out our <a href="https://www.sciencehistory.org/othmer-library/appointment" target="_blank">Research Appointment form</a>. Have questions about this or other collections? Contact Othmer Library reference staff at <a href="mailto:reference@sciencehistory.org" target="_top">reference@sciencehistory.org</a>.</p>
      </div>
    </div>
  </xsl:template>
  
  <!-- BIOGRAPHICAL/HISTORICAL NOTE-->
  <xsl:template match="ead:bioghist">
    <div id="bioghist" class="panel panel-default">
      <div class="panel-heading">
        <h2 class="panel-title"><xsl:copy-of select="ead:head"/></h2>
      </div>
      <div class="panel-body">
	  <xsl:for-each select="ead:p"/>
		<p><xsl:copy-of select="."/></p>
      </div>
    </div>
  </xsl:template>
  
  <!-- SCOPE AND CONTENTS -->
  <xsl:template match="ead:archdesc/ead:scopecontent">
    <div id="scope" class="panel panel-default">
      <div class="panel-heading">
        <h2 class="panel-title"><xsl:copy-of select="ead:head" /></h2>
      </div>
      <div class="panel-body">
        <xsl:copy-of select="ead:p" />
		<xsl:for-each select="ead:list/ead:item">
		<xsl:number value="position()" format="I"/>. 
		<xsl:value-of select="."/> <br/>
		</xsl:for-each>
      </div>
    </div>
  </xsl:template>

  <!-- TERMS AND ADMINISTRATIVE INFORMATION -->
  <xsl:template match="ead:archdesc">
    <div id="subjects" class="panel panel-default">
      <div class="panel-heading">
        <h2 class="panel-title">Subjects and Keywords</h2>
      </div>
      <div class="panel-body">
        <ul>
          <xsl:for-each select="ead:controlaccess/*[@source='lcsh']">
            <li><xsl:value-of select="." /></li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
    <div id="administrative" class="panel panel-default">
      <div class="panel-heading">
        <h2 class="panel-title">Administrative Information</h2>
      </div>
      <div class="panel-body">
        <p><span class="bold">Repository: </span><xsl:value-of select="ead:did/ead:repository/ead:corpname" /></p>
        <p>
          <span class="bold">
		  <xsl:value-of select="ead:accessrestrict/ead:head" />: </span>
		  <xsl:copy-of select="ead:accessrestrict/ead:p"/>
        </p>
        <p>
          <span class="bold"><xsl:value-of select="ead:userestrict/ead:head" />: </span>
          <xsl:value-of select="ead:userestrict/ead:p" />
        </p>
        <p><span class="bold">Acquisition Method: </span><xsl:value-of select="ead:acqinfo/ead:p" /></p>
        <p><span class="bold">Preferred Citation: </span><xsl:value-of select="ead:prefercite/ead:p" /></p>
        <p><span class="bold">Processing Information: </span><xsl:value-of select="ead:processinfo/ead:p" /></p>
        <!--<p><span class="bold">Other Note: </span><xsl:value-of select="ead:odd/ead:p" /></p>-->
      </div>
    </div>
  </xsl:template>

  <!-- BOX/FOLDER LISTING -->
   <xsl:template match="ead:archdesc/ead:dsc">
    <div id="listings" class="panel panel-default">
	<div class="panel-heading">
        <h2 class="panel-title">Collection Inventory</h2>
      </div>
      <div class="panel-last">
        <xsl:choose>
          <xsl:when test="ead:c[@level='series']">  
            <xsl:apply-templates select="ead:c[@level='series']" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="ead:c[@level='file' or @level='item']" />
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
</xsl:template>

  <!-- SERIES LEVEL -->
  <xsl:template match="ead:c[@level='series']">
    <xsl:for-each select=".">
      <ul class="series">
        <li>
		  <span class="bold"><xsl:value-of select="ead:did/ead:unittitle" /></span>
          <xsl:if test="ead:did/ead:unitdate">
            <xsl:text>, </xsl:text><xsl:value-of select="ead:did/ead:unitdate" />
          </xsl:if>
          <div class="desc"><xsl:copy-of select="ead:odd/ead:p" /></div>
		  <xsl:choose>
		  <xsl:when test="ead:c[@level='subseries']">
		     <xsl:apply-templates select="ead:c[@level='subseries']" />
		  </xsl:when>
		  <xsl:otherwise>
            <xsl:apply-templates select="ead:c[@level='file' or @level='item']" />
          </xsl:otherwise>
		  </xsl:choose>
        </li>
      </ul>
    </xsl:for-each>
  </xsl:template>

  <!-- SUB-SERIES LEVEL -->
  <xsl:template match="ead:c[@level='subseries']">
    <xsl:for-each select=".">
      <ul class="subseries">
        <li>
		  <span class="bold"><xsl:value-of select="ead:did/ead:unittitle" /></span>
          <xsl:if test="ead:did/ead:unitdate">
            <xsl:text>, </xsl:text><xsl:value-of select="ead:did/ead:unitdate" />
          </xsl:if>
          <div class="desc"><xsl:copy-of select="ead:odd/ead:p" /></div>
          <xsl:apply-templates select="ead:c[@level='subseries']" />
          <xsl:apply-templates select="ead:c[@level='file' or @level='item']" />
        </li>
      </ul>
    </xsl:for-each>
  </xsl:template>
  
  <!-- BOX & FOLDER LEVEL -->
  <xsl:template match="ead:c[@level='file' or @level='item']">
    <xsl:for-each select=".">
        <ul class="physloc">
            <li>
              Box 
			  <xsl:value-of select="ead:did/ead:container[@type='box']" />,
              <xsl:if test="ead:did/ead:container[@type='folder']">
			  folder 
			  <xsl:value-of select="ead:did/ead:container[@type='folder']"/>; 
			  </xsl:if>
              <xsl:value-of select="ead:did/ead:unittitle"/>
              (<xsl:value-of select="ead:did/ead:unitdate"/>)
			  <li>
			  <xsl:if test="ead:c/ead:odd">
			  <xsl:value-of select="ead:c/ead:odd/ead:head"/>: <xsl:value-of select="ead:c/ead:odd/ead:p"/>
			  </xsl:if>
			  </li>
              <xsl:if test="ead:did/ead:dao">
                  <ul class="digital-objects">
                  <xsl:for-each select="ead:did/ead:dao">
                     <li>
                       <xsl:element name="a">
                         <xsl:attribute name="href">
                            <xsl:value-of select="./@xlink:href" />
                         </xsl:attribute>
                         <xsl:attribute name="target">_blank</xsl:attribute>
                         <xsl:attribute name="class">digital-object-link</xsl:attribute>
                         <span class="small"><i class="fa fa-picture-o" aria-hidden="true"></i><xsl:value-of select="ead:daodesc/ead:p"/></span>
                       </xsl:element>
                     </li>
					 </xsl:for-each>
                  </ul>
             </xsl:if>
        </li>
	   </ul>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>