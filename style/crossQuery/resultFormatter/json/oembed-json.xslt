<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
>
  <xsl:import href="crossQuery-to-oembed.xslt"/>
  
  <xsl:param name="format" select="'json'"/>
  <xsl:param name="callback"/>

  <xsl:output indent="yes" method="text" encoding="UTF-8" media-type="application-json"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="number(/crossQueryResult/@totalDocs)=1">
        <!-- regex on callback parameter to sanitize user input -->
        <!-- http://www.w3.org/TR/xmlschema-2/ '\c' = the set of name characters, those ·match·ed by NameChar -->
        <xsl:if test="$callback">
          <xsl:value-of select="replace(replace($callback,'[^\c]',''),':','')"/>
          <xsl:text>(</xsl:text>
        </xsl:if>
          <xsl:apply-templates select="/crossQueryResult//docHit/meta" mode="x"/>
        <xsl:if test="$callback">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="r404"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
