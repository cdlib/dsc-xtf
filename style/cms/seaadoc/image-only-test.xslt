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


<!-- IMPORTANT (AND WHEN MOVING TO PRODUCTION): IF YOU CHANGE THE NAME OF THE CORRESPONDING HTML FILE, BE SURE TO CHANGE THE VALUE OF document() BELOW -->
<xsl:variable name="layout" select="document('image-test.xml')"/>


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
	<input type="hidden" name="xslt" value="stoubtest"/>
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
	<input type="hidden" name="xslt" value="stoub" />
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
<!--
  <xsl:choose>
    <xsl:when test="name()='type' and text()='image'">
-->
      <!-- img src="{../identifier}/hi-res" border="0"/ -->
      <img src="{../identifier}/FID3" border="0"/>
<!--
      <div class="thumbnail">
        <a href="{../identifier}/hi-res">
          <img src="{../identifier}/thumbnail" alt="Click on image for larger view" border="0"/>
        </a>
      </div>
-->

<!--
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
-->
</xsl:template>

<xsl:template match="qdc" mode="sr">
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="10"/></td>
        </tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="10"/></td>
  	      <td align="center" valign="center" width="100">
	        <xsl:apply-templates select="type" mode="sr"/>
	      </td>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="10"/></td>
        </tr>
        <tr>
          <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="10" height="10"/></td>
        </tr>

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
			<div class="thumbnail"><a href="{../identifier}"><img src="{../identifier}/thumbnail" alt="[Thumbnail]" border="0"/></a></div>
                </xsl:when>
                <xsl:otherwise>
			<span class="type"><xsl:apply-templates/></span>
                </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="creator" mode="metadata">
        <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="title[1]" mode="metadata">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="subject.series[1]" mode="metadata">
        <a href="{../relation.ispartof[1]}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="date" mode="metadata">
        <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="description" mode="metadata">
        <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="format.medium" mode="metadata">
        <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="subject | subject.lcsh" mode="metadata">
        <a href="?type=image;xslt=seaadoc-image-results-test;pageSize=4;search={.}">
          <xsl:value-of select="."/>
        </a>
        <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;|&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="publisher" mode="sr">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="identifier" mode="metadata">
        <xsl:text disable-output-escaping='yes'><![CDATA[<a href="]]></xsl:text>
	  <xsl:value-of select="."/>
        <xsl:text disable-output-escaping='yes'><![CDATA[">]]></xsl:text>
	  <xsl:value-of select="."/>
        <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
</xsl:template>

<xsl:template match="relation.ispartof" mode="metadata">
	<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	<span class="label">Is part of: </span> <a href="{.}"><xsl:value-of select="."/></a>
	<br />
</xsl:template>


</xsl:stylesheet>
