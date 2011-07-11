<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
  xmlns:json="./base-xml2json.xsl"
  exclude-result-prefixes="#all"
>

  <!-- oEmbed http://oembed.com/#section2.2 Consumer Request -->
  <!-- url param in the url is known by now; $url later is to the media file -->
  <xsl:param name="maxwidth"/>
  <xsl:param name="maxheight"/>
  <!-- format is set in the XSLT with the output element to make testing eaiser -->

  <xsl:include href="./base-xml2json.xsl"/>

  <xsl:template name="reference-image-position">
    <!-- need to check maxwidth and maxheight -->
    <xsl:value-of select="number(1)"/>
  </xsl:template>

  <!-- data mapping -->
  <xsl:template match="meta" mode="x">
    <xsl:variable name="type" select="if (reference-image) then 'photo' else 'link'"/>
    <xsl:variable name="reference-image-position">
      <xsl:call-template name="reference-image-position"/>
    </xsl:variable>
    <xsl:variable name="width" select="if (reference-image) then reference-image[position()=$reference-image-position]/@X else ''"/>
    <xsl:variable name="height" select="if (reference-image) then reference-image[position()=$reference-image-position]/@Y else ''"/>
    <xsl:variable name="url" select="if (reference-image) then concat(
      'http://content.cdlib.org',
      reference-image[position()=$reference-image-position]/@src
    ) else ''"/>
    <xsl:variable name="title" select="title[1]"/>
    <xsl:variable name="author_name" select="creator"/>
    <!-- xsl:variable name="author_url" select=""/ -->
    <xsl:variable name="provider_name" select="concat(
      facet-institution,
      ', ',
      substring-after((relation-from)[1],'|')
    )"/>
    <xsl:variable name="provider_url" select="substring-before((relation-from)[1],'|')"/>
    <xsl:choose>
      <xsl:when test="$format='json'">
        <xsl:call-template name="json-result">
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="height" select="$height"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="url" select="$url"/>
          <xsl:with-param name="author_name" select="$author_name"/>
          <xsl:with-param name="provider_name" select="$provider_name"/>
          <xsl:with-param name="provider_url" select="$provider_url"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xml-result">
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="height" select="$height"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="url" select="$url"/>
          <xsl:with-param name="author_name" select="$author_name"/>
          <xsl:with-param name="provider_name" select="$provider_name"/>
          <xsl:with-param name="provider_url" select="$provider_url"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-result">
    <xsl:param name="type"/>
    <xsl:param name="width"/>
    <xsl:param name="height"/>
    <xsl:param name="title"/>
    <xsl:param name="url"/>
    <xsl:param name="author_name"/>
    <xsl:param name="provider_name"/>
    <xsl:param name="provider_url"/>
      <xsl:text>{</xsl:text>
          "type": <xsl:value-of select="json:escape-string($type)"/><xsl:text>,</xsl:text>
        <xsl:if test="$type='photo'"><xsl:text>
          "width": </xsl:text><xsl:value-of select="json:escape-string($width)"/><xsl:text>,
          "height": </xsl:text><xsl:value-of select="json:escape-string($height)"/><xsl:text>,
          "url": </xsl:text><xsl:value-of select="json:escape-string($url)"/><xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:if test="$author_name"><xsl:text>
          "author_name": </xsl:text><xsl:value-of select="json:escape-string($author_name)"/><xsl:text>,</xsl:text>
        </xsl:if><xsl:text>
        "title": </xsl:text><xsl:value-of select="json:escape-string($title)"/><xsl:text>,
        "provider_name": </xsl:text><xsl:value-of select="json:escape-string($provider_name)"/><xsl:text>,
        "provider_url": </xsl:text><xsl:value-of select="json:escape-string($provider_url)"/><xsl:text>,
        "version": "1.0"
      }</xsl:text>
  </xsl:template>

  <xsl:template name="xml-result">
    <xsl:param name="type"/>
    <xsl:param name="width"/>
    <xsl:param name="height"/>
    <xsl:param name="title"/>
    <xsl:param name="url"/>
    <xsl:param name="author_name"/>
    <xsl:param name="provider_name"/>
    <xsl:param name="provider_url"/>
      <oembed>
        <version>1.0</version>
        <type><xsl:value-of select="$type"/></type>
        <xsl:if test="$type='photo'">
          <width><xsl:value-of select="$width"/></width>
          <height><xsl:value-of select="$height"/></height>
          <url><xsl:value-of select="$url"/></url>
        </xsl:if>
        <title><xsl:value-of select="$title"/></title>
        <author_name><xsl:value-of select="$author_name"/></author_name>
        <provider_name><xsl:value-of select="$provider_name"/></provider_name>
        <provider_url><xsl:value-of select="$provider_url"/></provider_url>
      </oembed>
  </xsl:template>

  <xsl:template name="r404">
    <redirect:sendHttpError code="404" message="url not found" 
      xmlns:redirect="java:/org.cdlib.xtf.saxonExt.Redirect" 
      xsl:extension-element-prefixes="redirect"/> 
  </xsl:template>

</xsl:stylesheet>
