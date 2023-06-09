<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:util:compiler-eqname-utils:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Local components
   -->

   <!--
      Regular expression to capture NCName
      
      Based on https://github.com/xspec/xspec/blob/fb7f63d8190a5ccfea5c6a21b2ee142164a7c92c/src/schemas/xspec.rnc#L329
   -->
   <xsl:variable as="xs:string" name="local:capture-NCName">([\i-[:]][\c-[:]]*)</xsl:variable>

   <!--
      Resolves URIQualifiedName to xs:QName
   -->
   <xsl:function as="xs:QName" name="local:resolve-UQName">
      <xsl:param as="xs:string" name="uqname" />

      <xsl:variable as="xs:string" name="regex">
         <xsl:value-of xml:space="preserve">
            <!-- based on https://github.com/xspec/xspec/blob/fb7f63d8190a5ccfea5c6a21b2ee142164a7c92c/src/schemas/xspec.rnc#L329 -->
            ^
               Q\{
                  ([^\{\}]*)                                   <!-- group 1: URI -->
               \}
               <xsl:value-of select="$local:capture-NCName" /> <!-- group 2: local name -->
            $
         </xsl:value-of>
      </xsl:variable>

      <xsl:analyze-string flags="x" regex="{$regex}" select="$uqname">
         <xsl:matching-substring>
            <xsl:sequence select="QName(regex-group(1), regex-group(2))" />
         </xsl:matching-substring>
      </xsl:analyze-string>
   </xsl:function>

</xsl:stylesheet>
