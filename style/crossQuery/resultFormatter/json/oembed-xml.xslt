<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
>
  <xsl:import href="crossQuery-to-oembed.xslt"/>
  
  <xsl:param name="format" select='xml'/>

  <xsl:output indent="yes" method="xml" encoding="UTF-8" media-type="text/xml"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="number(/crossQueryResult/@totalDocs)=1">
        <xsl:apply-templates select="/crossQueryResult//docHit/meta" mode="x"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="r404"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
