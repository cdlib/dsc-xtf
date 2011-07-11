<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- oEmbed query parser stylesheet                                         -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<!-- oEmbed http://oembed.com/#section2.2 Consumer Request 
url maxwidth maxheight format
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/"
                              xmlns:xlink="http://www.w3.org/TR/xlink" 
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:parse="http://cdlib.org/parse" 
                              xmlns:session="java:org.cdlib.xtf.xslt.Session" 
                              exclude-result-prefixes="xsl dc mets xlink xs parse">

  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="format" select="'json'"/>

  <xsl:template match="/">
    <query 
      indexPath="index" 
      termLimit="1000" 
      workLimit="20000000" 
      style="{
        if ($format='xml') 
        then 'style/crossQuery/resultFormatter/json/oembed-xml.xslt'
        else 'style/crossQuery/resultFormatter/json/oembed-json.xslt'
      }" 
      startDoc="1" 
      maxDocs="1"
    >
      <and field="identifier">
        <xsl:apply-templates select="parameters/param[@name='url']/token"/>
      </and>
      </query>
  </xsl:template>
  
  <xsl:template match="token[@isWord='yes'][not(@value='http')][not(@value='content.cdlib.org')]">
    <term>
      <xsl:value-of select="@value"/>
    </term>
  </xsl:template>


</xsl:stylesheet>

<!--
   Copyright (c) 2011, Regents of the University of California
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

