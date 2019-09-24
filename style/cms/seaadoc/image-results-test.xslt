<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" media-type="text/html" />
<xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

<!--    image-results.xslt -->
<!--  	Displays the search results when searching images  -->
<!--  	Version 1.0. April 16, 2004 -->

<!--    Check for updates at: -->
<!--    http://www.cdlib.org/inside/diglib/repository/customize/templates.html -->

<!-- 	Credit for idea of using an HTML template goes to Eric van der Vlist. -->
<!-- 	For details, see: -->
<!-- 	http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html -->



<xsl:variable name="page" select="/"/>
<xsl:param name="staff" />



<!-- IMPORTANT (AND WHEN MOVING TO PRODUCTION): IF YOU CHANGE THE NAME OF THE CORRESPONDING HTML FILE, BE SURE TO CHANGE THE VALUE OF document() BELOW -->
<xsl:variable name="layout" select="document('results-test.xml')"/>

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


<!-- DEFINE CUSTOM STUFF -->
<xsl:param name="format"/>
<xsl:param name="dummy"/>

<!-- DEFINE CUSTOM TAGS FOR DYNAMIC ELEMENTS IN THE HTML FILE -->

<!-- USING <insert-Query/> IN THE HTML FILE INSERTS A SEARCH FORM -->

<xsl:template match="insert-Query">
        <xsl:apply-templates select="$page/SearchResults/Query" mode="form" />
</xsl:template>

<xsl:template match="word" mode="sr">
	<xsl:apply-templates select="text()"/>
</xsl:template>

<xsl:template match="Query" mode="form">
	<!--strong>New search:</strong-->
<!-- IMPORTANT: WHILE TESTING, USE action="/cgi/generic-search?" -->
<!-- WHEN MOVING TO PRODUCTION, USE action="/?"  -->
	<!-- form name="refine" method="GET" action="/cgi/generic-search?" -->
	<form name="refine" method="GET" action="?">

<!-- WHEN MOVING TO PRODUCTION: CHANGE THE value="" TO THE CORRECT xslt= ALIAS -->
	<input type="hidden" name="xslt" value=""/>
<!-- IMPORTANT: ADD ANY ADDITIONAL HIDDEN FORM PARAMETERS TO LIMIT TO YOUR COLLECTION  -->
	<input type="hidden" name="type" value="image"/>
	<xsl:apply-templates select="word" mode="form"/>
	<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
	<input name="image2" type="submit" alt="Search" class="button" value="Another Search"/>
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
<!--  <xsl:if test="$staff='yes'"> Staff: yes "$staff" </xsl:if>
<xsl:if test="$staff='no'"> Staff: no "$staff" </xsl:if>
-->
Your search for <em><font color="#FF9933"><strong>
<!--xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'search']" mode="sr" /-->
  <!--xsl:apply-templates select="$page/SearchResults/Query/term/@word" mode="sr" /-->
 
   <xsl:choose>
    <xsl:when test="$dummy">
      <xsl:value-of select="$dummy" />   
    </xsl:when>   
    <xsl:when test="$page/SearchResults/Query/word/@index = 'search'">
      <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'search']" mode="sr" />
    </xsl:when>


    <xsl:when test="$page/SearchResults/Query/word/@index = 'type'">
      <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'type']" mode="sr" />
    </xsl:when>

    <xsl:when test="$page/SearchResults/Query/word/@index = 'subject'">
      <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'subject']" mode="sr" />
    </xsl:when>
<!--
    <xsl:when test="$page/SearchResults/Query/word/@index = 'title'">
      <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'title']" mode="sr" />
    </xsl:when>
    <xsl:when test="$page/SearchResults/Query/word/@index = 'description'">
      <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'description']" mode="sr" />
    </xsl:when>
    <xsl:when test="$page/SearchResults/Query/word/@index = 'creator'">
      <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'creator']" mode="sr" />
    </xsl:when>
-->
    <xsl:otherwise>
  	  <xsl:value-of select="$format"/>
    </xsl:otherwise>
  </xsl:choose>

  </strong></font></em> found <font color="#FF9933"><strong><em>
  <xsl:value-of select="@hits"/></em></strong></font> items

  
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
	Displaying <xsl:value-of select="@start"/> - <xsl:value-of select="@end"/> of <xsl:value-of select="@hits"/> records
</xsl:template>

<xsl:template match="Query" mode="hits">
</xsl:template>

<!-- USING <insert-previous/> AND <insert-next/> IN THE HTML FILE ALLOWS USERS TO NAVIGATE TO THE NEXT AND PREVIOUS PAGES OF SEARCH RESULTS-->
<xsl:template match="insert-previous">
        <xsl:apply-templates select="$page/SearchResults/previous" mode="sr" />
</xsl:template>

<xsl:template match="previous" mode="sr">
	<span class="prevNext"><a href="{.}">&lt; BACK</a></span>
</xsl:template>

<xsl:template match="insert-next">
        <xsl:apply-templates select="$page/SearchResults/next" mode="sr" />
</xsl:template>

<xsl:template match="next" mode="sr">
	<span class="prevNext"><a href="{.}">NEXT &gt;</a></span>
</xsl:template>



<!-- USING <insert-Fisheye/> IN THE HTML FILE ALLOWS USERS TO NAVIGATE TO THE NEXT AND PREVIOUS GROUPS OF RESULT PAGES -->
<xsl:template match="insert-Fisheye">
<xsl:if test="(count($page/SearchResults/page) &gt; 1) or (number($page/SearchResults/page/@n) &gt; 1)">
        <!--Go to page:-->
        <xsl:apply-templates select="$page/SearchResults/previousGroup" mode="sr" />
        <xsl:apply-templates select="$page/SearchResults/page" mode="sr" />
        <xsl:apply-templates select="$page/SearchResults/nextGroup" mode="sr" />
</xsl:if>
</xsl:template>

<xsl:template match="previousGroup" mode="sr">
	   <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a href="{.}"></a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
 </xsl:template>

<xsl:template match="nextGroup" mode="sr">
	   <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a href="{.}"></a>   <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="page" mode="sr">

	   <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<xsl:choose>
        <xsl:when test="text()">
                <a href="{.}"><xsl:value-of select="@n"/></a>
        </xsl:when>
        <xsl:otherwise>
                [<xsl:value-of select="@n"/>]
        </xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- USING <insert-suggest/> IN THE HTML FILE SUGGEST ALTERNATIVES TO POSSIBLY MISSPELLED WORDS -->
<xsl:template match="insert-suggest">
	<xsl:if test="$page/SearchResults/Query/term/suggest">
<!-- IMPORTANT: WHILE TESTING, USE action="/cgi/generic-search?" -->
<!-- WHEN MOVING TO PRODUCTION, USE action="/?"  -->
	<!-- form method="GET" action="/cgi/generic-search?" -->
	<form method="GET" action="?">
<!-- IMPORTANT (AND WHEN MOVING TO PRODUCTION): CHANGE THE value="" TO THE CORRECT xslt= ALIAS -->
	<input type="hidden" name="xslt" value="seaadoc-image-results-test" />
<!-- IMPORTANT: ADD ANY ADDITIONAL HIDDEN FORM PARAMETERS TO LIMIT TO YOUR COLLECTION  -->
	<input type="hidden" name="relation" value="lib.uci.edu/seaadoc" />

	
	<input type="hidden" name="pageSize" value="8" />
	
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
  <table class="sr" border="0" cellpadding="5" cellspacing="0" width="100%">
    <tr>
      <xsl:choose>
        <xsl:when test="qdc">
          <xsl:apply-templates select="qdc" mode="sr"/>
        </xsl:when>
    	  <xsl:otherwise>
	      <!-- tr><td><p class="directions"><ul>
             <span class="help">
               <img alt="Tip:" src="http://jarda.cdlib.org/images/search/Tip.gif" width="25" height="16" border="0" />
               <strong> Helpful hints to improve your results</strong>: Try simple and direct words (example: if you want to view texts concerning hospitals use "hospitals" and not "medical facilities"). If you want more results, try a broader word (example: try "medical" not "hospitals").<br/>
             </span>
          </ul></p></td></tr-->
          <script language="JavaScript">
//            window.open("http://seaadoc.lib.uci.edu/nohits.html","noresults","width=400,height=300");
// 050415 cc - pass the search parameter to nohits.html
            <xsl:text disable-output-escaping='yes'><![CDATA[window.open("http://seaadoc.lib.uci.edu/nohits.html?search=]]></xsl:text>
            <xsl:choose>
              <xsl:when test="$dummy">
                <xsl:value-of select="$dummy" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$page/SearchResults/Query/word[@index = 'search']" mode="sr" />
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping='yes'><![CDATA[","noresults","resizable=1,width=400,height=300");]]></xsl:text>
            history.go(-1);
          </script>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </table>
</xsl:template>

<xsl:template match="@*|*">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>


<!-- IMPORTANT: FOR EACH <qdc> ELEMENT, DEFINE WHAT MARKUP YOU'D LIKE TO DISPLAY -->
<xsl:template match='*' mode="sr">
  <xsl:variable name="id4url" select="substring-after(../identifier,'ark:/')" />

  <xsl:choose>
    <xsl:when test="name()='type' and text()='image'">
      <!-- div class="thumbnail" -->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<img src="{../identifier}/thumbnail" alt="Click for details" border="0" height="150"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<img src="{../identifier}/thumbnail" alt="Click for details" border="0" height="150"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

      <!-- /div -->
    </xsl:when>

    <xsl:when test="name()='type' and text()='image collection'">

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<img src="{../identifier}/thumbnail" height="150" alt="Click for details" border="0"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<img src="{../identifier}/thumbnail" height="150" alt="Click for details" border="0"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

    </xsl:when>

    <xsl:when test="name()='type' and text()='facsimile text'">

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<img src="{../identifier}/thumbnail" height="150" alt="Click for details" border="0"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<img src="{../identifier}/thumbnail" height="150" alt="Click for details" border="0"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

    </xsl:when>

    <xsl:when test="name()='type' and text()='cartographic'">

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<img src="{../identifier}/thumbnail" alt="Click for details" border="0" height="150"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<img src="{../identifier}/thumbnail" alt="Click for details" border="0" height="150"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

    </xsl:when>

    <xsl:when test="name()='type' and text()='text'">
<!--
      <xsl:text disable-output-escaping='yes'><![CDATA[<a href="http://ark-dev.cdlib.org:8086/ark:/]]></xsl:text>
      <xsl:value-of select="substring-after(../identifier,'ark:/')" />
      <xsl:text disable-output-escaping='yes'><![CDATA[">]]></xsl:text>
      <img src="http://seaadoc.lib.uci.edu/uc.gif" width="200" alt="[Encoded Text Placeholder Image]" border="0"/>
      <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
-->

<!-- changed staff value check to allow for no passed value, assumes no value means staff=no.  05/20/2010 MFV -->
		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<img src="http://seaadoc.lib.uci.edu/uc.gif" height="150" alt="Click for details" border="0"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<img src="http://seaadoc.lib.uci.edu/uc.gif" height="150" alt="Click for details" border="0"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

    </xsl:when>

    <xsl:otherwise>
      <span class="type"><xsl:apply-templates/></span>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>


<xsl:template match="qdc" mode="sr">
  <xsl:if test="position() = 5">
    <td width="4%"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="5"/></td>
    <xsl:text disable-output-escaping='yes'><![CDATA[</tr>]]></xsl:text>
    <tr><td colspan="3"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="5"/></td></tr>
    <xsl:text disable-output-escaping='yes'><![CDATA[<tr>]]></xsl:text>
  </xsl:if>
  <td width="4%"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="5"/></td>
  <td height="220" width="20%" valign="top">
	<table class="sr" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr align="center" valign="bottom">
   	    <td colspan="3" width="150" height="150" align="center" valign="bottom">
          <xsl:apply-templates select="type" mode="sr"/>
        </td>
	  </tr>
	  <tr><td colspan="3"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="10"/></td></tr>

      <tr valign="top">
        <td class="resultstitles" align="right">Title:</td>
        <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="5"/></td>
        <td class="resultstext" align="left">
          <xsl:apply-templates select="title" mode="sr"/>
        </td>
      </tr>

	  <tr><td colspan="3"><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="5"/></td></tr>
      <tr valign="top">
        <td class="resultstitles" align="right">Date:</td>
        <td><img src="http://seaadoc.lib.uci.edu/images/spacer.gif" width="5" height="5"/></td>
        <td class="resultstext" align="left">
          <xsl:choose>
            <xsl:when test="./date.created">
              <xsl:apply-templates select="date.created[1]" mode="sr"/>
            </xsl:when>
            <xsl:otherwise>
              unknown
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </table>
  </td>
</xsl:template>


<xsl:template match="creator" mode="sr">
	<p><span class="label">Creator: </span> <xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="date.created" mode="sr">
    <p><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="description" mode="sr">
	<p><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="format" mode="sr">
	<p><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="identifier" mode="moreinfo">
<!-- IMPORTANT: WHILE TESTING, USE http://ark-dev.cdlib.org:8085/cgi/generic-search?" -->
<!-- WHEN MOVING TO PRODUCTION, USE http://ark.cdlib.org/?"  -->
<!-- IMPORTANT (AND WHEN MOVING TO PRODUCTION): CHANGE THE URL BELOW TO THE CORRECT xslt= ALIAS -->
	<p><a href="?xslt=seaadoc-image-single-test;identifier={../identifier[1]}">View details...</a></p>
</xsl:template>

<xsl:template match="identifier" mode="sr">
</xsl:template>

<xsl:template match="publisher" mode="sr">
	<p><xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="relation.ispartof[1]" mode="sr">
</xsl:template>

<xsl:template match="relation.ispartof[2]" mode="sr">
	<xsl:value-of select="name()"/>
	<a href="{.}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="subject.series[1]" mode="sr">
	<p><a href="{../relation.ispartof[1]}"><xsl:value-of select="."/></a></p>
</xsl:template>

<xsl:template match="subject" mode="sr">
    <!--<a href="?relation=jarda;type=image;xslt=stoubtest;search={.}">-->
	  <xsl:value-of select="."/>
    <!--</a>-->
</xsl:template>

<xsl:template match="title[1]" mode="sr">
  <xsl:variable name="id4url" select="substring-after(../identifier,'ark:/')" />

  <xsl:variable name="title">
	<xsl:choose>
	  <xsl:when test="string-length(.) &gt; 90">
		<xsl:value-of select="substring(.,1,90)"/>...
	  </xsl:when>
	  <xsl:otherwise>
		<xsl:value-of select="."/>
	  </xsl:otherwise>
 	</xsl:choose>
  </xsl:variable>

  <p>
	<xsl:choose>
	  <xsl:when test="../type = 'text'">
<!--
        <xsl:text disable-output-escaping='yes'><![CDATA[<a href="http://ark-dev.cdlib.org:8086/ark:/]]></xsl:text>
        <xsl:value-of select="substring-after(../identifier,'ark:/')" />
        <xsl:text disable-output-escaping='yes'><![CDATA[">]]></xsl:text>
        <xsl:value-of select="$title"/>
        <xsl:text disable-output-escaping='yes'><![CDATA[</a>]]></xsl:text>
-->
        <!-- a href="http://ark-dev.cdlib.org:8086/ark:/{$id4url}" target="_blank" -->



		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<xsl:value-of select="$title"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<xsl:value-of select="$title"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>


	  </xsl:when>
	  <xsl:otherwise>


		<xsl:choose>
			<xsl:when test="$staff = 'yes'">
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=yes">
					<xsl:value-of select="$title"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="?xslt=seaadoc-image-single-test;identifier={$id4url};staff=no">
					<xsl:value-of select="$title"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

	  </xsl:otherwise>
 	</xsl:choose>
    </p>
</xsl:template>



</xsl:stylesheet>
