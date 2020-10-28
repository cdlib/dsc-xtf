<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >

    <xsl:variable name="OAI_page_size" select="'2000'"/>

<xsl:template name="setList">
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>ucm_li</setSpec>
    <setName>The Ruth and Sherman Lee Institute of Japanese Art</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>oac:images</setSpec>
    <setName>Online Archive of California: Images</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>oac:text</setSpec>
    <setName>Online Archive of California: Texts</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>oac:ead</setSpec>
    <setName>Online Archive of California: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>cuwr:ead</setSpec>
    <setName>Water Resources Center Archives: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>cuwr:objects</setSpec>
    <setName>Water Resources Center Archives: Digital Objects</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>clloy:ead</setSpec>
    <setName>Loyola Marymount University, Department of Archives and Special Collections, William H. Hannon Library: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec></setSpec>
    <setName>California Polytechnic State University - San Luis Obispo: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>css:ead</setSpec>
    <setName>California State University, Sacramento Library: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>cslusp:ead</setSpec>
    <setName>California Polytechnic State University - San Luis Obispo: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>clloy:objects</setSpec>
    <setName>Loyola Marymount University, Department of Archives and Special Collections, William H. Hannon Library: Digital Objects</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>scu:ead</setSpec>
    <setName>Santa Clara University: EAD Finding Aids</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>scu:objects</setSpec>
    <setName>Santa Clara University: Digital Objects</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>css:objects</setSpec>
    <setName>California State University, Sacramento Library: Objects</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>calavc:ead</setSpec>
    <setName>Visual Communications Archives and Media Resource Library</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>bancroft:objects</setSpec>
    <setName>Bancroft Library Digital Objects</setName>
  </set>
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>huntington:ead</setSpec>
    <setName>Huntington Library: EAD Finding Aids</setName>
  </set>
  <!--
  <set xmlns="http://www.openarchives.org/OAI/2.0/">
    <setSpec>calavc:objects</setSpec>
    <setName>Visual Communications Archives and Media Resource Library</setName>
  </set>
  -->
</xsl:template>

<xsl:template name="setQuery">
  <xsl:param name="set"/>
  <xsl:choose>
    <xsl:when test="$set='ucm_li'">
	<and field="relation">
           <term>ark</term>
           <term>13030/kt500023mk</term>
	</and>
    </xsl:when>
    <xsl:when test="$set='oac:images'">
        <and field="relation">
          <term>oac.cdlib.org</term>
        </and>
        <and field="type">
          <term>image</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='oac:text'">
        <and field="type">
          <term>text</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='oac:ead'">
        <and field="oac4-tab">
           <term>Collections::ead</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='cuwr:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
          <term>U::UC Riverside::Water Resources Collections and Archives*</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='cuwr:objects'">
        <and field="relation">
	  <phrase>
            <term>http</term>
            <term>library.ucr.edu</term>
            <term>wrca</term>
          </phrase>
        </and>
        <and>
          <not field="type"> 
          <phrase>
           <term>archival</term>
           <term>collection</term>
          </phrase>
          </not>
        </and>
    </xsl:when>
    <xsl:when test="$set='clloy:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
          <term>L::Loyola Marymount University, Department of Archives and Special Collections, William H. Hannon Library*</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='clloy:objects'">
	<and field="relation">
           <term>ark</term>
           <term>13030/kt9k402381</term>
	</and>
    <and>
        <or>
            <and field="oac4-tab">
                <term>Items::image</term>
            </and>
            <and field="oac4-tab">
                <term>Items::text</term>
            </and>
        </or>
    </and>
    </xsl:when>
    <xsl:when test="$set='cslusp:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
            <term>C::California Polytechnic State University - San Luis Obispo*</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='css:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
            <term>C::California State University, Sacramento Library*</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='scu:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
            <term>S::Santa Clara University*</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='scu:objects'">
	<and field="relation">
           <term>ark</term>
           <term>13030/tf9v19p891</term>
	</and>
    <and>
        <or>
            <and field="oac4-tab">
                <term>Items::image</term>
            </and>
            <and field="oac4-tab">
                <term>Items::text</term>
            </and>
        </or>
    </and>
    </xsl:when>
    <xsl:when test="$set='css:objects'">
	<and field="relation">
           <term>ark</term>
           <term>13030/kt796nc8ds</term>
	</and>
    <and>
        <or>
            <and field="oac4-tab">
                <term>Items::image</term>
            </and>
            <and field="oac4-tab">
                <term>Items::text</term>
            </and>
        </or>
    </and>
    </xsl:when>
    <xsl:when test="$set='calavc:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
            <term>V::Visual Communications Archives and Media Resource Library</term>
        </and>
    </xsl:when>
    <xsl:when test="$set='bancroft:objects'">
	<and field="facet-institution">
           <term>UC Berkeley::Bancroft Library</term>
	</and>
    <and>
        <or>
            <and field="oac4-tab">
                <term>Items::image</term>
            </and>
            <and field="oac4-tab">
                <term>Items::text</term>
            </and>
        </or>
    </and>
    </xsl:when>
    <xsl:when test="$set='huntington:ead'">
        <and field="oac4-tab">
          <term>Collections::ead</term>
        </and>
        <and field="institution-doublelist">
          <term>H::Huntington Library*</term>
        </and>
    </xsl:when>
    <!--
    <xsl:when test="$set='calavc:objects'">
	<and field="relation">
           <term>ark</term>
           <term>13030/kt8w10405k</term>
	</and>
    <and>
        <or>
            <and field="oac4-tab">
                <term>Items::image</term>
            </and>
            <and field="oac4-tab">
                <term>Items::text</term>
            </and>
        </or>
    </and>
    </xsl:when>
    -->
    <xsl:otherwise>
      Paramter set=<xsl:value-of select="$set"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
