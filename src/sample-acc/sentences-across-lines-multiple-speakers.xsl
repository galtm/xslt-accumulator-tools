<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:mode use-accumulators="#all"/>
    
    <!--
        At a <line> element, accumulator-after('sentences') returns 
        a sequence of sentences through the end of that line. Sentences
        that continue on a subsequent line will be returned incomplete.

        At the document node or outermost element, accumulator-after('sentences')
        returns a sequence of sentences with all continuations resolved.
    -->
    <xsl:accumulator name="sentences" initial-value="()"
        as="element(sentence)*">
        <xsl:accumulator-rule match="sentence">
            <xsl:choose>
                <xsl:when test="not(@continues != '')">
                    <!-- No continuation. Add sentence to sequence. -->
                    <xsl:sequence select="($value, .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Append to the correct existing sentence. Preserve unrelated sentences. -->
                    <xsl:variable name="this-sentence" select="." as="element(sentence)"/>
                    <xsl:variable name="continues" select="@continues" as="xs:string"/>
                    <xsl:iterate select="$value">
                        <xsl:choose>
                            <xsl:when test="string(@id) = $continues">
                                <sentence>
                                    <!-- Keep old attributes and add new ones, except @continues -->
                                    <xsl:sequence select="attribute() |
                                        $this-sentence/@*[not(name()='continues')]"/>
                                    <!-- Keep earlier content and append new content -->
                                    <xsl:sequence select="node()"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:sequence select="$this-sentence/node()"/>
                                </sentence>                                
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Pass sentence through unchanged -->
                                <xsl:sequence select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:iterate>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:accumulator-rule>
    </xsl:accumulator>

    <xsl:template match="/">
        <!-- Debugger usage: Try putting a breakpoint on the next line
            and using the XWatch pane in Oxygen to view accumulator values. -->
        <sentences>
            <xsl:text>Sentences or sentence fragments through the 3rd line are:</xsl:text>
            <xsl:for-each select="descendant::line[3]/accumulator-after('sentences')">
                <xsl:sort select="@id"/>
                <xsl:sequence select="."/>
            </xsl:for-each>
        </sentences>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="sentence">
        <!-- Debugger usage: Try putting a breakpoint on the next line
            and using the XWatch pane in Oxygen to view accumulator values. -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="text()"/>
</xsl:stylesheet>