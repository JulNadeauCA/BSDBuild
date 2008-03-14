<xsl:stylesheet version = '1.0'
 xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>

<xsl:output method="html"/>
<xsl:param name="lang"/>

<xsl:template match="ml">
  <xsl:if test="$lang=@lang"> 
    <xsl:apply-templates select="*|text()"/>
  </xsl:if>
</xsl:template>

<xsl:template match="*|@*|text()">
   <xsl:copy>
      <xsl:apply-templates select="*|@*|text()"/>
   </xsl:copy>
</xsl:template>

</xsl:stylesheet>
