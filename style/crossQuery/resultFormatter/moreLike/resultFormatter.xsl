<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:editURL="http://cdlib.org/xtf/editURL"
	exclude-result-prefixes="#all"
	xmlns:tmpl="xslt://template">

<!-- DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd" -->
<xsl:import href="../common/editURL.xsl"/>
<xsl:include href="../../../common/SSI.xsl"/>
<xsl:include href="../../../common/online-items-graphic-element.xsl"/>
<xsl:include href="../../../common/scaleImage.xsl"/>

  <xsl:output method="xhtml"
    indent="yes"
	      encoding="UTF-8" media-type="text/html; charset=UTF-8" 
        omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<xsl:template match="/">
<html>
  <xsl:if test="crossQueryResult/docHit[contains(meta/type[1],'image')]"><div>More like this</div></xsl:if>
  <xsl:apply-templates select="crossQueryResult/docHit"/>
        <xsl:comment>
        xslt: <xsl:value-of select="static-base-uri()"/>
        </xsl:comment>
</html>
</xsl:template>


  <xsl:template match="docHit[not(contains(meta/type[1],'image'))]"/>

  <xsl:template match="docHit[contains(lower-case(meta/type[1]),'image')]">
    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    <xsl:variable name="xy">
      <xsl:call-template name="scale-max">
        <xsl:with-param name="max" select="50"/>
        <xsl:with-param name="x" select="meta/thumbnail/@X"/>
        <xsl:with-param name="y" select="meta/thumbnail/@Y"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="height" select="$xy/xy/@height"/>
    <xsl:variable name="width" select="$xy/xy/@width"/>

    <div>
      <a href="{replace(meta/identifier[1],'http://ark.cdlib.org','')}" onclick="_gaq.push(['cst._trackEvent', 'moreLike', 'click', window.title]);">
      <img src="{replace($fullark,'http://ark.cdlib.org','')}/thumbnail" height="{$height}" width="{$width}"/>
         <xsl:value-of select="meta/title[1]"/>
      </a>
    </div>
  </xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
<!--
   Copyright (c) 2005, Regents of the University of California
   All rights reserved.
 
   Redistribution and use in source and binary forms, with or without 
   modification, are permitted provided that the following conditions are 
   met:

   - Redistributions of source code must retain the above copyright notice, 
     this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright 
     notice, this list of conditions and the following disclaimer in the 
     documentation and/or other materials provided with the distribution.
   - Neither the name of the University of California nor the names of its
     contributors may be used to endorse or promote products derived from 
     this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
   POSSIBILITY OF SUCH DAMAGE.
-->
