<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xtf="http://cdlib.org/xtf"
                xmlns:editURL="http://cdlib.org/xtf/editURL" 
                version="2.0">
        
    <xsl:import href="../../common/editURL.xsl"/>

    <xsl:param name="keyword"/>
    <xsl:param name="keyword-add"/>
    <xsl:param name="fieldList"/>    
    <xsl:param name="azBrowse"/>    
    <xsl:param name="ethBrowse"/>    
    <xsl:param name="xtfURL"/>
    
<!-- ====================================================================== -->
<!-- Format Query for Display                                               -->
<!-- ====================================================================== -->
    
    <xsl:template name="format-query">
        <xsl:param name="nomatches"/>

        <xsl:choose>
            <xsl:when test="$azBrowse">
                <xsl:value-of select="$azBrowse"/>
                <xsl:if test="$keyword-add">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$keyword-add"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$ethBrowse">
                <xsl:value-of select="$ethBrowse"/>
                <xsl:if test="$keyword-add">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$keyword-add"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$jardaBrowse">
                <xsl:value-of select="$jardaBrowse"/>
                <xsl:if test="$keyword-add">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$keyword-add"/>
                </xsl:if>
            </xsl:when>
            <!-- keyword -->
            <xsl:when test="$keyword">
                "<xsl:value-of select="$keyword"/>"
                <xsl:if test="$keyword-add">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$keyword-add"/>
                </xsl:if>
                <xsl:apply-templates select="query" mode="query">
                    <xsl:with-param name="nomatches" select="$nomatches"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$keyword">
                <xsl:value-of select="$keyword"/>
                <xsl:choose>
                    <!-- if they did not search all fields, tell them which are in the fieldList -->
                    <xsl:when test="$fieldList">
                        <xsl:text> in </xsl:text>
                        <span class="search-type">
                            <xsl:value-of select="replace($fieldList,'\s',', ')"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> in </xsl:text>
                        <span class="search-type"> keywords</span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="query" mode="query">
                    <xsl:with-param name="nomatches" select="$nomatches"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="and|or|near|range|not" mode="query">
        <xsl:param name="nomatches"/>
        <xsl:choose>
            <xsl:when test="matches(@field, 'relation')"/>    
            <xsl:when test="@field">    
                <xsl:choose>
                    <xsl:when test="$nomatches">
                        in 
                    <xsl:apply-templates mode="query">
                        <xsl:with-param name="nomatches" select="$nomatches"/>
                    </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                    <div class="cali-facet">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="editURL:remove(replace(concat($xtfURL, $crossqueryPath, '?',  $queryString), '&amp;', ';'), replace(@field, 'facet-', ''))"/>
                            </xsl:attribute>
                                &#x24E7;</a>
                    <xsl:apply-templates mode="query">
                        <xsl:with-param name="nomatches" select="$nomatches"/>
                    </xsl:apply-templates>
                        <xsl:choose>
                            <xsl:when test="@field = 'text'">
                                <xsl:text> in </xsl:text>
                                <span class="search-type">
                                <xsl:text> the full text </xsl:text>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--<xsl:value-of select="@field"/> -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="query">
                        <xsl:with-param name="nomatches" select="$nomatches"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="exact" mode="query">
        <xsl:text>'</xsl:text>
        <span class="search-term">
            <xsl:value-of select="term"/>
        </span>
        <xsl:text>'</xsl:text>
        <xsl:if test="@field">
            <xsl:text> in </xsl:text>
            <span class="search-type">
                <xsl:value-of select="@field"/>
            </span>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="term" mode="query">
        <!--
        TERM |
        <xsl:value-of select="$keyword"/>|
        <xsl:value-of select="$keyword-add"/>|
        <xsl:value-of select="."/>|
        <xsl:value-of select="name(.)"/>|
        -->
        <xsl:variable name="keyword-norm" select="normalize-space($keyword)"/>
        <xsl:variable name="keyword-add-norm" select="normalize-space($keyword-add)"/>
        <xsl:variable name="this-norm" select="normalize-space(.)"/>
        <!--
        <xsl:value-of select="$keyword-norm"/>|
        <xsl:value-of select="$keyword-add-norm"/>|
        <xsl:value-of select="$this-norm"/>|
        -->
        <!--
        <xsl:if test="preceding-sibling::term and (. != $keyword) and (. != $keyword-add)">
            -->
        <xsl:if test="preceding-sibling::term and ($this-norm != $keyword-norm) and ($this-norm != $keyword-add-norm)">
            <xsl:value-of select="name(..)"/>
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="($this-norm != $keyword-norm) and ($this-norm != $keyword-add-norm)">
        <span class="search-term">
            <!--<xsl:if test="../@field != 'text'">
            <xsl:value-of select="../@field"/>
            </xsl:if-->
            <xsl:value-of select="."/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:if>
    </xsl:template>
    
    <xsl:template match="phrase" mode="query">
        <xsl:text>&quot;</xsl:text>
        <span class="search-term">
            <xsl:value-of select="term"/>
        </span>
        <xsl:text>&quot;</xsl:text>
    </xsl:template>
    
    <xsl:template match="upper" mode="query">
        <xsl:if test="../lower != .">
            <xsl:text> - </xsl:text>
            <xsl:apply-templates mode="query"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
