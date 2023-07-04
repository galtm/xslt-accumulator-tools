<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:at="http://github.com/galtm/xslt-accumulator-tools"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:mode use-accumulators="#all"/>
    
    <!-- Record position and term for glossary entries. At a glossentry
        or glossterm element, you can retrieve data as follows:
        * accumulator-before('glossentry-position') returns
          map{ "position": N } where N is an integer.
        * accumulator-after('glossentry-position') returns
          map{ "position": N, "term": string value of glossterm }
        -->
    <xsl:accumulator name="glossentry-position" as="map(xs:string,item())"
        initial-value="map{'position': 0}">
        <xsl:accumulator-rule match="db:glossentry" phase="start">
            <!-- At glossentry start, increment the position. Don't record the term yet. -->
            <xsl:sequence select="map{'position': ($value('position') + 1)}"/>
        </xsl:accumulator-rule>
            
        <xsl:accumulator-rule match="db:glossterm/descendant::text()">
            <!-- At glossterm end, keep the position and record the term.
                In case a term has multiple text nodes, accumulate them. -->
            <xsl:sequence select="map{
                'position': $value('position'),
                'term': $value('term') || string(.)
                }"/>
        </xsl:accumulator-rule>
    </xsl:accumulator>

</xsl:stylesheet>