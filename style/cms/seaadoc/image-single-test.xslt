<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" media-type="text/html" />
<xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

<!--    image-single-test.xslt -->
<!--  	Displays metadata for a single image (test version)-->
<!--  	Version 1.0. April 16, 2004 -->

<!--    Check for updates at: -->
<!--    http://www.cdlib.org/inside/diglib/repository/customize/templates.html -->


<!-- 	Credit for idea of using an HTML template goes to Eric van der Vlist. -->
<!-- 	For details, see: -->
<!-- 	http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html -->


<xsl:variable name="page" select="/"/>
<xsl:param name="staff" />


<!-- IMPORTANT (AND WHEN MOVING TO PRODUCTION): IF YOU CHANGE THE NAME OF THE CORRESPONDING HTML FILE, BE SURE TO CHANGE THE VALUE OF document() BELOW -->

<xsl:variable name="layout" select="document('single-test.xml')"/>


<xsl:template match="/">
    <xsl:apply-templates select="$layout/html"/>
</xsl:template>



<!-- USING &nbsp; OR &copy; OR OTHER STANDARD ENTITY REFERENCES IN THE HTML FILE WILL NOT WORK -->
<!-- TO WORKAROUND THIS, DEFINE <nbsp/> AND <copy/> TAGS FOR USE IN THE HTML FILE -->

<xsl:template match="nbsp">
  <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="copy">
  <xsl:text disable-output-escaping='yes'><![CDATA[&copy;]]></xsl:text>
</xsl:template>


<!-- NOTE: IF YOUR HTML FILE NEEDS TO USE OTHER ENTITY REFERENCES, DEFINE THEM BELOW -->

<xsl:template match="amp">
  <xsl:text disable-output-escaping='yes'><![CDATA[&amp;]]></xsl:text>
</xsl:template>


<!-- DEFINE CUSTOM PARAMS -->
<xsl:variable name="id4url" select="substring-after($page/SearchResults/qdc/identifier,'ark:/')" />
<xsl:variable name="id4php" select="substring-after($page/SearchResults/qdc/identifier,'ark:/13030/')" />


<!-- DEFINE CUSTOM TAGS FOR DYNAMIC ELEMENTS IN THE HTML FILE -->

<xsl:template match="jsBACKopen">
  <xsl:text disable-output-escaping='yes'><![CDATA[<script language="JavaScript" type="text/JavaScript">]]></xsl:text>
  <xsl:text disable-output-escaping='yes'><![CDATA[document.write('<a href="' + document.referrer + '">');]]></xsl:text>
  <xsl:text disable-output-escaping='yes'><![CDATA[</script>]]></xsl:text>
</xsl:template>

<xsl:template match="jsBACKclose">
  <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
</xsl:template>


<!-- USING <insert-Query/> IN THE HTML FILE INSERTS A SEARCH FORM -->

<xsl:template match="insert-Query">
        <xsl:apply-templates select="$page/SearchResults/Query" mode="form" />
</xsl:template>

<xsl:template match="word" mode="sr">
	<xsl:apply-templates select="text()"/>
</xsl:template>

<xsl:template match="Query" mode="form">
	<strong>New search:</strong>
<!-- IMPORTANT: WHILE TESTING, USE action="/cgi/generic-search?" -->
<!-- WHEN MOVING TO PRODUCTION, USE action="/?"  -->
	<form name="refine" method="GET" action="/cgi/generic-search?">

<!-- WHEN MOVING TO PRODUCTION: CHANGE THE value="" TO THE CORRECT xslt= ALIAS -->
	<!-- input type="hidden" name="xslt" value="stoubtest"/ -->
	<input type="hidden" name="xslt" value="seaadoc-image-results-test"/>
<!-- IMPORTANT: ADD ANY ADDITIONAL HIDDEN FORM PARAMETERS TO LIMIT TO YOUR COLLECTION  -->
<xsl:apply-templates select="word" mode="form"/>
	<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
	<input name="image2" type="submit" alt="Search" class="button" value="Search"/>
	</form>
</xsl:template>


<xsl:template match="word" mode="form">
	<xsl:choose>
	<xsl:when test="@index='search'">
		<input name="{@index}" value="{text()}"/>
	</xsl:when>
	<xsl:otherwise>
	<input type="hidden" name="{@index}" value="{text()}"/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- USING <insert-SummaryShort/> IN THE HTML FILE INSERTS THE QUERY TERMS AND NUMBER OF HITS -->
<xsl:template match="insert-SummaryShort">
        <xsl:apply-templates select="$page/SearchResults" mode="Summary1" />
</xsl:template>

<xsl:template match="SearchResults" mode="Summary1">
Your search for <strong><xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'search']" mode="sr" /></strong> in <em>Texts</em> found <xsl:value-of select="@hits"/> items
</xsl:template>

<xsl:template match="Query" mode="Summary1">
        <xsl:apply-templates select="mode" mode="Summary1"/>
        <xsl:apply-templates select="word" mode="Summary1"/>
</xsl:template>

<xsl:template match="word" mode="Summary1">
<xsl:if test="@index != 'search'">
        <xsl:value-of select="@index"/>=
</xsl:if>
        <xsl:apply-templates mode="Summary1"/>
</xsl:template>

<xsl:template match="mode" mode="Summary1">
        <xsl:if test="text()">
<xsl:value-of select="text()"/> =
        </xsl:if>
</xsl:template>


<!-- USING <insert-SearchSummary/> IN THE HTML FILE DISPLAYS THE NUMBER OF RESULTS ON THIS PAGE -->
<xsl:template match="insert-SearchSummary">
        <xsl:apply-templates select="$page/SearchResults" mode="summary" />
</xsl:template>

<xsl:template match="SearchResults" mode="summary">
	Displaying <xsl:value-of select="@start"/> - <xsl:value-of select="@end"/> of <xsl:value-of select="@hits"/> images
</xsl:template>

<xsl:template match="Query" mode="hits">
</xsl:template>


<!-- USING <insert-previous/> AND <insert-next/> IN THE HTML FILE ALLOWS USERS TO NAVIGATE TO THE NEXT AND PREVIOUS PAGES OF SEARCH RESULTS-->
<xsl:template match="insert-previous">
        <xsl:apply-templates select="$page/SearchResults/previous" mode="sr" />
</xsl:template>

<xsl:template match="previous" mode="sr">
	<span class="prevNext"><a href="{.}">Previous page</a></span>
</xsl:template>

<xsl:template match="insert-next">
        <xsl:apply-templates select="$page/SearchResults/next" mode="sr" />
</xsl:template>

<xsl:template match="next" mode="sr">
	<span class="prevNext"><a href="{.}">Next page</a></span>
</xsl:template>


<!-- USING <insert-Fisheye/> IN THE HTML FILE ALLOWS USERS TO NAVIGATE TO THE NEXT AND PREVIOUS GROUPS OF RESULT PAGES -->
<xsl:template match="insert-Fisheye">
<xsl:if test="(count($page/SearchResults/page) &gt; 1) or (number($page/SearchResults/page/@n) &gt; 1)">
        More Results Pages:
        <xsl:apply-templates select="$page/SearchResults/previousGroup" mode="sr" />
        <xsl:apply-templates select="$page/SearchResults/page" mode="sr" />
        <xsl:apply-templates select="$page/SearchResults/nextGroup" mode="sr" />
</xsl:if>
</xsl:template>

<xsl:template match="previousGroup" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <a href="{.}"></a> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="nextGroup" mode="sr">
	<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <a href="{.}"></a> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="page" mode="sr">
	<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<xsl:choose>
        <xsl:when test="text()">
                <a href="{.}"><xsl:value-of select="@n"/></a>
        </xsl:when>
        <xsl:otherwise>
                <xsl:value-of select="@n"/>
        </xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- USING <insert-suggest/> IN THE HTML FILE SUGGEST ALTERNATIVES TO POSSIBLY MISSPELLED WORDS -->
<xsl:template match="insert-suggest">
	<xsl:if test="$page/SearchResults/Query/term/suggest">
<!-- IMPORTANT: WHILE TESTING, USE action="/cgi/generic-search?" -->
<!-- IMPORTANT: IN PRODUCTION, USE action="/?"  -->
	<form method="GET" action="/cgi/generic-search?">
<!-- IMPORTANT: CHANGE THE value="" TO THE CORRECT xslt= ALIAS -->
<!-- IMPORTANT: ADD ANY ADDITIONAL HIDDEN FORM PARAMETERS TO LIMIT TO YOUR COLLECTION  -->
	<!-- input type="hidden" name="xslt" value="stoub" / -->
	<input type="hidden" name="xslt" value="seaadoc-image-results-test" />
	You may have misspelled something.<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
        Did you mean: <xsl:apply-templates select="$page/SearchResults/Query/term" mode="sr" />
	<input type="submit" value="Use this spelling" />
        </form>
	</xsl:if>
</xsl:template>

<xsl:template match="term" mode="sr">
	<select name="search"><xsl:apply-templates mode="sr"/></select>
</xsl:template>

<xsl:template match="suggest" mode="sr">
	<option><xsl:apply-templates/></option>
</xsl:template>



<!-- USING <insert-SearchResults/> IN THE HTML FILE DISPLAYS SEARCH RESULTS (OR DISPLAY A "ZERO RESULTS" MESSAGE)-->
<xsl:template match="insert-SearchResults">
        <xsl:apply-templates select="$page/SearchResults" mode="sr" />
</xsl:template>

<xsl:template match="SearchResults" mode="sr">
	<table class="sr" border="0" cellpadding="0" cellspacing="0" width="100%">
	<xsl:choose>
	        <xsl:when test="qdc">
  		    <xsl:apply-templates select="qdc" mode="sr"/>
	        </xsl:when>
	        <xsl:otherwise>
			<tr><td><p class="directions">
			<ul>
        		<span class="help"><img alt="Tip:" src="http://jarda.cdlib.org/images/search/Tip.gif" width="25" height="16" border="0" /> <strong> Helpful hints to improve your results</strong>: Try simple and direct words (example: if you want to view texts concerning hospitals use "hospitals" and not "medical facilities"). If you want more results, try a broader word (example: try "medical" not "hospitals").<br/>
			</span>
		      </ul></p></td></tr>
        	</xsl:otherwise>
	</xsl:choose>
	</table>
</xsl:template>


<xsl:template match="@*|*">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>


<!-- IMPORTANT: CHOOSE WHICH <qdc> ELEMENTS TO DISPLAY AND IN WHAT ORDER TO DISPLAY THEM -->

<xsl:template match='*' mode="sr">

<!-- debug
<xsl:value-of select="name()"/><br />
<xsl:value-of select="text()"/><br />
-->

  <xsl:choose>
    <xsl:when test="name()='type' and text()='image'">
      <!-- div class="thumbnail" -->
        <!-- a href="{../identifier}" -->
        <!-- a href="?xslt=seaadoc-image-only-test;identifier={../identifier}" target="_blank" -->
<!-- 03202007 AC changed the link to alternative viewer so as to get the largest image
       <a href="?xslt=seaadoc-image-only-test;identifier={$id4url}" target="_blank">    -->
<!-- TEMPORARY EMERGENCY FIX PENDING ASSISTANCE FROM CDL 05/17/2012 vegamf
<a href="http://content.cdlib.org/ark:/{$id4url}/?brand=oac" target="_blank">
-->
		<a href="http://seaadoc.lib.uci.edu/display_image.php?ID={$id4php}" target="_blank">
          <!-- img src="http://seaadoc.lib.uci.edu/uc.gif" width="200" alt="[Link To Image Image]" border="0"/ -->
          <!-- img src="{../identifier}/thumbnail" alt="[Thumbnail]" border="0"/ -->
          <img src="{../identifier}/thumbnail" height="150" alt="[Link To Image]" border="0"/>
        </a>
      <!-- /div -->
    </xsl:when>

    <xsl:when test="name()='type' and text()='image collection'">
 
 <!-- AC 102108     <a href="http://ark-dev.cdlib.org:8086/ark:/{$id4url}" target="_blank"> -->
 <!-- AC 102208 added brand=oac so that link goes to oac rather than calisphere -->
  <a href="http://content.cdlib.org/ark:/{$id4url}/?brand=oac" target="_blank">
   <!--Ac 102208       <a href="http://seaadoc.lib.uci.edu/display_image.php?ID={$id4url}/" target="_blank"> -->
        <!-- img src="http://seaadoc.lib.uci.edu/c_viewer.jpg" alt="[Link To Image Collection Image]" border="0"/ -->
        <img src="{../identifier}/thumbnail" height="150" alt="[Link To Image Collection]" border="0"/>
      </a>
<!--
      <xsl:text disable-output-escaping='yes'><![CDATA[<a href="#" onclick="javascript:window.open('http://ark-dev.cdlib.org:8086]]></xsl:text>
      <xsl:value-of select="substring($page/SearchResults/qdc/identifier,21,23)"/>
      <xsl:text disable-output-escaping='yes'><![CDATA[');">]]></xsl:text>
        <img src="http://seaadoc.lib.uci.edu/c_viewer.jpg" alt="[Link To Image Collection Image]" border="0"/>
      <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
-->
    </xsl:when>

    <xsl:when test="name()='type' and text()='facsimile text'">
      <!-- AC 102108 <a href="http://ark-dev.cdlib.org:8086/ark:/{$id4url}" target="_blank"> -->
        <a href="http://content.cdlib.org/ark:/{$id4url}/?brand=oac" target="_blank">
        <img src="{../identifier}/thumbnail" height="150" alt="[Link To Scanned Text]" border="0"/>
      </a>
    </xsl:when>

    <xsl:when test="name()='type' and text()='cartographic'">
      <a href="?xslt=seaadoc-image-only-test;identifier={$id4url}" target="_blank">
        <img src="{../identifier}/thumbnail" height="150" alt="[Link To Image]" border="0"/>
      </a>
    </xsl:when>

    <xsl:when test="name()='type' and text()='text'">
      <!-- Ac 102108 <a href="http://ark-dev.cdlib.org:8086/ark:/{$id4url}" target="_blank"> -->
      <a href="http://content.cdlib.org/ark:/{$id4url}/?brand=oac" target="_blank">
      
        <img src="http://seaadoc.lib.uci.edu/uc.gif" height="150" alt="Click for details" border="0"/>
        <!-- img src="{../identifier}/thumbnail" height="150" alt="[Link To Image]" border="0"/ -->
      </a>
    </xsl:when>

    <xsl:otherwise>
      <span class="type"><xsl:apply-templates/></span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="qdc" mode="sr">
    <tr>
      <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="12"/></td>
    </tr>
	<tr>
      <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
  	  <td align="right" valign="center" width="100">
	    <xsl:apply-templates select="type" mode="sr"/>
	  </td>
      <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
	  <td>
	    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
          <tr>
                <td class="resultstitles" align="right" valign="top">Title:</td>
                <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
                <td class="bodytext" width="90%"><xsl:apply-templates select="title" mode="metadata" /></td>
	      </tr>
          <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
          <tr>
                <td class="resultstitles" align="right" valign="top">Date:</td>
                <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
                <td class="bodytext">
                  <xsl:choose>
                    <xsl:when test="$page/SearchResults/qdc/date.created">
                      <xsl:apply-templates select="date.created[1]" mode="metadata"/>
                    </xsl:when>
                    <xsl:otherwise>
                      unknown
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
	      </tr>

<xsl:if test="$page/SearchResults/qdc/contributor">
          <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
          <tr>
                <td class="resultstitles" align="right" valign="top">Creator(s):</td>
                <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
                <!-- td class="bodytext"><xsl:apply-templates select="creator" mode="metadata"/></td -->
                <td class="bodytext"><xsl:apply-templates select="contributor" mode="metadata"/></td>
	      </tr>
</xsl:if>

          <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
          <tr>
                <td class="resultstitles" align="right" valign="top">Format:</td>
                <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
                <td class="bodytext"><xsl:apply-templates select="format" mode="metadata"/></td>
	      </tr>

<xsl:if test="$page/SearchResults/qdc/language">
          <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
          <tr>
                <td class="resultstitles" align="right" valign="top">Language:</td>
                <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
                <td class="bodytext">
                  <xsl:apply-templates select="language" mode="metadata"/>
                </td>
	      </tr>
</xsl:if>

            </table>
          </td>
        </tr>

        <tr><td colspan="4"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="12"/></td></tr>

<xsl:if test="$page/SearchResults/qdc/description">
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Notes:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="description" mode="metadata"/>
          </td>
        </tr>
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
</xsl:if>

        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Subjects (testing):</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="subject | subject.lcsh" mode="metadata"/>

<xsl:if test="$page/SearchResults/qdc/coverage">
            <xsl:apply-templates select="coverage" mode="metadata"/>
</xsl:if>

            <xsl:apply-templates select="type.mods[2]" mode="metadata"/>
            <xsl:apply-templates select="type.genreform" mode="metadata"/>
            <xsl:apply-templates select="coverage.spatial" mode="metadata"/>
          </td>
        </tr>
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>

<!-- 050408 cc removed by request
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Repository:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="publisher" mode="metadata"/>
          </td>
        </tr>
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
-->
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Collection ID:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="subject.series[1]" mode="metadata"/>  
          </td>
        </tr>
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Item ID:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <!-- cc xsl:apply-templates select="identifier" mode="metadata"/-->
            <xsl:apply-templates select="identifier.mods" mode="metadata"/>
          </td>
        </tr>
      
<!--  added by archana on 020107 oto add Rights field  -->
   
 <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>

        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Rights:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <!-- cc xsl:apply-templates select="identifier" mode="metadata"/-->
            <xsl:apply-templates select="rights" mode="metadata"/>
          </td>
        </tr>
        
<!--  upto here   -->

<!--    <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>  --> 
<xsl:if test="$staff = 'yes'">	
  	    <!-- temporary Development Extras header -->
<!--	    <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr> -->
	    <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
 <!--AC as per Workticket #: 200711159 -->
        <tr>
          <td colspan="3"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td><font size="3"><u>Development Extras:</u></font></td>
        </tr>

  	    <!-- temporary raw CDL XML offering -->
 <!--AC as per Workticket #: 200711159 -->
		
	    <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>

        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">View CDL XML Output</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center"> 
            <!-- a href="?xslt=raw+xml;identifier={identifier}" target="_blank" -->
 <!--AC as per Workticket #: 200711159 -->

            <a href="?xslt=raw+xml;identifier={$id4url}" target="_blank">
              Click here to see the raw CDL XML returned for this item.
            </a>
          </td>
        </tr>

   	    <!-- temporary raw METS XML offering -->
 <!--AC as per Workticket #: 200711159 -->

	    <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top"> View METS XML output:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
<!-- AC 012308 this link is out of date as per Brian Tingle's email dtd today 
            <a href="http://ark-dev.cdlib.org:8086/raw/ark:/{$id4url}/" target="_blank">  -->
            <a href="http://content.cdlib.org/mets/ark:/{$id4url}/" target="_blank">

              Click here to see the raw METS XML returned for this item.
            </a>
          </td>
        </tr>
</xsl:if>



<xsl:choose>
  <xsl:when test="$page/SearchResults/qdc/type = 'image collection'">
  </xsl:when>
  <xsl:when test="$page/SearchResults/qdc/type = 'facsimile text'">
  </xsl:when>
  <xsl:otherwise>
   	    <!-- temporary alternative viewer offering -->
<!-- AC112807 suppressing the alternate viewer
	    <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top"> Use alternate viewer:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <a href="http://seaadoc.lib.uci.edu/display_image.php?ID={$id4php}" target="_blank">
              Click here to view this item with the alternative PHP viewer.
            </a>
          </td>
        </tr> -->
  </xsl:otherwise>
</xsl:choose>

<!-- 050419 cc - moved this up to the Subjects: line
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Coverage:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="coverage" mode="metadata"/>
          </td>
        </tr>
-->

<!-- 050419 cc - moved this up to the Creator: line
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Contributor(s):</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="contributor" mode="metadata"/>
          </td>
        </tr>
-->

<!-- 050519 cc - moved this up under Format:
<xsl:if test="$page/SearchResults/qdc/language">
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="resultstitles" align="right" valign="top">Language:</td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td>
          <td class="bodytext" colspan="4" align="left" valign="center">
            <xsl:apply-templates select="language" mode="metadata"/>
          </td>
        </tr>
</xsl:if>
-->
        <tr><td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="8"/></td></tr>

<!--
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text><br />
	<xsl:apply-templates select="identifier" mode="metadata"/>
-->
<!--<p><a href="http://jarda.cdlib.org/copyright.html">Terms and Conditions of Use</a></p>-->
<!--	<xsl:apply-templates select="identifier | relation.ispartof" mode="metadata"/>-->
<!--
      <div class="questionContact">
	  <p><strong>Want to Learn More?</strong></p>
          <ul><li>Do you have a question about this item?</li>
             <li>Would you like to view the original version?</li>
            <li>Are you seeking permission to publish or reproduce this item?</li></ul>
	<p>Please contact the <a href="http://jarda.cdlib.org/about-rev.html#inst">Owning Institution</a>.</p>
	<p><img alt="Tip:" src="http://jarda.cdlib.org/images/search/Tip.gif" width="25" height="16" border="0" /> To learn more about these issues, please see the <a href="http://jarda.cdlib.org/faq.html">Frequently Asked Questions</a>.</p>
	</div> -->
<!--	</td>
	</tr>
-->

</xsl:template>



<!-- IMPORTANT: FOR EACH <qdc> ELEMENT, DEFINE WHAT MARKUP YOU'D LIKE TO DISPLAY -->

<xsl:template match='*' mode="metadata">
  <xsl:choose>
    <xsl:when test="name()='type' and text()='image'">
      <div class="thumbnail">
        <!--a href="{../identifier}"-->
        <a href="?xslt=seaadoc-image-only-test;identifier={../identifier}" target="_blank">
          <img src="http://seaadoc.lib.uci.edu/uc.gif" width="200" alt="[Development Placeholder Image]" border="0"/>
          <!-- img src="{../identifier}/thumbnail" alt="[Thumbnail]" border="0"/ -->
        </a>
      </div>
    </xsl:when>

    <xsl:when test="name()='type' and text()='image collection'">
        <a href="?xslt=seaadoc-image-only-test;identifier={../identifier}" target="_blank">
          <img src="http://seaadoc.lib.uci.edu/uc.gif" width="200" alt="[Image Collection Placeholder Image]" border="0"/>
        </a>
    </xsl:when>

    <xsl:otherwise>
      <span class="type"><xsl:apply-templates/></span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="contributor" mode="metadata">
  <!-- xsl:for-each select="$page/SearchResults/qdc/contributor" -->

  <xsl:for-each select=".">
<!-- 050419 cc - the links aren't working properly, so i'm taking out the anchors
    <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={.};contributor={.}">
      <xsl:value-of select="."/>
    </a>
-->
    <xsl:if test=". != ../contributor[1]">
      <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
    </xsl:if>
    <xsl:value-of select="."/>
  </xsl:for-each>

<!-- 050419 cc - iam going to cheese out here and *ASSUME* that there will never be more than 3 contributors...
     050513 cc - stupid me!  ignore the above!
  <xsl:value-of select="."/>

  <xsl:if test="$page/SearchResults/qdc/contributor[2]">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
    <xsl:value-of select="$page/SearchResults/qdc/contributor[2]"/>
  </xsl:if>

  <xsl:if test="$page/SearchResults/qdc/contributor[3]">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
    <xsl:value-of select="$page/SearchResults/qdc/contributor[3]"/>
  </xsl:if>
-->
</xsl:template>

<xsl:template match="coverage" mode="metadata">
  <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={.};coverage={.}">
    <xsl:value-of select="."/>
  </a>
</xsl:template>

<xsl:template match="creator" mode="metadata">
  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={.};creator={.}">
    <xsl:value-of select="."/>
  </a>
</xsl:template>

<xsl:template match="date.created" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="description" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="rights" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="format" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="identifier" mode="metadata">
<!--
     <xsl:text disable-output-escaping='yes'><![CDATA[<a href="]]></xsl:text>
	 <xsl:value-of select="."/>
     <xsl:text disable-output-escaping='yes'><![CDATA[">]]></xsl:text>
	 <xsl:value-of select="."/>
     <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
-->
  <a href="{.}">
    <xsl:value-of select="."/>
  </a>
</xsl:template>

<xsl:template match="identifier.mods" mode="substring">
    <xsl:value-of select="substring(.,13,3)"/>
</xsl:template>

<xsl:template match="identifier.mods" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="language" mode="metadata">
  <xsl:variable name="mappedlang">
    <xsl:choose>
      <xsl:when test=". = 'cam'">Cambodian</xsl:when>
      <xsl:when test=". = 'eng'">English</xsl:when>
      <xsl:when test=". = 'hmo'">Hmong</xsl:when>
      <xsl:when test=". = 'lao'">Laotian</xsl:when>
      <xsl:when test=". = 'vie'">Vietnamese</xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:for-each select=".">
    <xsl:if test=". != ../language[1]">
      <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
    </xsl:if>
<!-- ac changed the link this one works too   <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={$mappedlang};language={.}">-->
    
	<!-- AC 012208 -->
<!--	
	 <xsl:if test="$staff = 'yes'">	
	    <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;language={.};search={.};staff=yes">
      <xsl:value-of select="$mappedlang"/>  
	 </a>
	 </xsl:if> 

	 <xsl:if test="$staff = 'no'">	
	    <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;language={.};search={.};staff=no">
      <xsl:value-of select="$mappedlang"/>  
	 </a>
	 </xsl:if>
-->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
    <xsl:choose>
        <xsl:when test="$staff = 'yes'">
            <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;language={.};search={.};staff=yes">
                <xsl:value-of select="$mappedlang"/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;language={.};search={.};staff=no">
                <xsl:value-of select="$mappedlang"/>
            </a>
        </xsl:otherwise>
    </xsl:choose>
	
  </xsl:for-each>
<!--
     <xsl:value-of select="."/>
     <xsl:apply-templates select="." mode="remap"/>

  <xsl:if test="$page/SearchResults/qdc/language[2]">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
    <xsl:value-of select="$page/SearchResults/qdc/language[2]"/>
	<xsl:apply-templates select="$page/SearchResults/qdc/language[2]" mode="remap"/>
  </xsl:if>

    <xsl:if test="$page/SearchResults/qdc/language[3]">
    <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
    <xsl:value-of select="$page/SearchResults/qdc/language[3]"/>
	<xsl:apply-templates select="$page/SearchResults/qdc/language[3]" mode="remap"/>
  </xsl:if>
-->
</xsl:template>

<!--
<xsl:template match="language" mode="remap">
  <xsl:variable name="mappedlang">
    <xsl:choose>
      <xsl:when test=". = 'eng'">
        English
      </xsl:when>
      <xsl:when test=". = 'vie'">
        Vietnamese
      </xsl:when>
      <xsl:when test=". = 'hmo'">
        Hmong
      </xsl:when>
      <xsl:when test=". = 'lao'">
        Laotian
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
</xsl:template>
-->

<xsl:template match="publisher" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="relation.ispartof" mode="metadata">
	 <xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	 <span class="label">Is part of: </span>
     <a href="{.}"><xsl:value-of select="."/></a>   
 <!--    <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;subject={.}">   -->
	 <br />
</xsl:template>

<xsl:template match="subject | subject.lcsh" mode="metadata">
     <xsl:if test=". != ../subject[1]">

<!-- <xsl:if test="position() != first() && position() != last()"> -->
<xsl:if test="position() != 1">
       <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
</xsl:if>

     </xsl:if>
	 
	 <!-- Ac Jan 22, 08-->
<!--
	 <xsl:if test="$staff = 'yes'">
     <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;subject={.};staff=yes">
      <xsl:value-of select="."/>
	 </a>
	 </xsl:if>

	 <xsl:if test="$staff = 'no'">	
     <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;subject={.};staff=no">
      <xsl:value-of select="."/>
	  </a>
	 </xsl:if>
-->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
    <xsl:choose>
        <xsl:when test="$staff = 'yes'">
            <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;subject={.};staff=yes">
                <xsl:value-of select="."/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;subject={.};staff=no">
                <xsl:value-of select="."/>
            </a>
        </xsl:otherwise>
    </xsl:choose>
     
</xsl:template>

<xsl:template match="subject.series" mode="metadata">
  <xsl:choose>
    <xsl:when test="substring(../identifier.mods,13,3) = 'bk-'">
      none
    </xsl:when>

    <xsl:when test=". = 'California Cultures' or . = 'SEAAdoc'">
      <xsl:choose>
        <xsl:when test="../subject.series[2] = 'California Cultures' or ../subject.series[2] = 'SEAAdoc'">
          <xsl:apply-templates select="../subject.series[3]" mode="collection"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="../subject.series[2]" mode="collection"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <xsl:apply-templates select="../subject.series[1]" mode="collection"/>
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<xsl:template match="subject.series" mode="collection">
     <!-- AC 012208 -->
<!--
 	 <xsl:if test="$staff = 'yes'">	
      <a href="/cms?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;pageSize=8;subject={../subject.series[1]};staff=yes"> <xsl:value-of select="."/></a>   
	 </xsl:if>
 	<xsl:if test="$staff = 'no'">	
      <a href="/cms?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;pageSize=8;subject={../subject.series[1]};staff=no"> <xsl:value-of select="."/></a>   
	 </xsl:if>
-->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
    <xsl:choose>
        <xsl:when test="$staff = 'yes'">
            <a href="/cms?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;pageSize=8;subject={../subject.series[1]};staff=yes">
                <xsl:value-of select="."/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a href="/cms?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;pageSize=8;subject={../subject.series[1]};staff=no">
                <xsl:value-of select="."/>
            </a>
        </xsl:otherwise>
    </xsl:choose>

<!-- changed by archana 070208 to the above line of code
as this link from collection id was not working
     <a href="{../relation.ispartof[1]}" target="_blank"><xsl:value-of select="."/></a> -->  


      |  MS-SEA
      <xsl:apply-templates select="../identifier.mods" mode="substring"/>
      |  Special Collections and Archives, The UCI Libraries, Irvine, California
</xsl:template>

<xsl:template match="title[1]" mode="metadata">
     <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="type.mods" mode="metadata">
  <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={.};type={substring(.,1,4)}*">
    <xsl:value-of select="."/>
  </a>

<!--
  <xsl:text disable-output-escaping='yes'><![CDATA[<a 
href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy=]]></xsl:text>
  <xsl:value-of select="."/>
  <xsl:text disable-output-escaping='yes'><![CDATA[;format=]]></xsl:text>
  <xsl:value-of select="substring(.,1,3)"/>
  <xsl:text disable-output-escaping='yes'><![CDATA[*">]]></xsl:text>
  <xsl:value-of select="."/>
  <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
-->

</xsl:template>


<xsl:template match="type.genreform" mode="metadata">
  <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
<!-- 032607 AC is trying to make this link work -->
<!--  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={.};type={substring(.,1,4)}*">
 AC 012208 -->
<!-- 
  <xsl:if test="$staff = 'yes'">	
  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;search={.};staff=yes">  
	  <xsl:value-of select="."/>
  </a>
	 </xsl:if>
 
  <xsl:if test="$staff = 'no'">	
  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;search={.};staff=no">  
	   <xsl:value-of select="."/>
  </a>
	 </xsl:if>
-->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
    <xsl:choose>
        <xsl:when test="$staff = 'yes'">
            <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;search={.};staff=yes">
                <xsl:value-of select="."/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;submit=search;search={.};staff=no">
                <xsl:value-of select="."/>
            </a>
        </xsl:otherwise>
    </xsl:choose>
   
</xsl:template>

<xsl:template match="coverage.spatial" mode="metadata">
  <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
<!-- 032607 AC is trying to make this link work -->
<!--  <a href="?xslt=seaadoc-image-results-test;relation=www.lib.uci.edu/seaadoc/;pageSize=8;dummy={.};type={substring(.,1,4)}*">--> 

<!--
  <xsl:if test="$staff = 'yes'">	
  <a href="?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;submit=search;pageSize=8;search={.};staff=yes"> 
    <xsl:value-of select="."/>
  </a>
  </xsl:if>
  <xsl:if test="$staff = 'no'">	
 <a href="?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;submit=search;pageSize=8;search={.};staff=no"> 
    <xsl:value-of select="."/>
  </a>
  </xsl:if>
-->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
    <xsl:choose>
        <xsl:when test="$staff = 'yes'">
            <a href="?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;submit=search;pageSize=8;search={.};staff=yes">
                <xsl:value-of select="."/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a href="?relation=www.lib.uci.edu/seaadoc/;xslt=seaadoc-image-results-test;submit=search;pageSize=8;search={.};staff=no">
                <xsl:value-of select="."/>
            </a>
        </xsl:otherwise>
    </xsl:choose>
  
</xsl:template>

</xsl:stylesheet>

