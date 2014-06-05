<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="#local"
	exclude-result-prefixes="xs local">

<xsl:output method="text" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="help requirement label" />

<xsl:template match="/">
	<xsl:apply-templates select="*">
		<xsl:with-param name="path" select="''" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="*">
	<xsl:param name="path" required="yes" />
	<xsl:variable name="path" select="concat($path, '/', position())" />
	<xsl:if test="text() and not(p)">
		<xsl:value-of select="$path" />
		<xsl:text>: </xsl:text>
		<xsl:apply-templates mode="inline" />
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
	<xsl:apply-templates select="@* | *">
		<xsl:with-param name="path" select="$path" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="strong | a | em">
</xsl:template>
		
<xsl:template match="strong | a | em" mode="inline">
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="name()" />
	<xsl:for-each select="@*">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()" />
		<xsl:text>="</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>"</xsl:text>
	</xsl:for-each>
	<xsl:text>&gt;</xsl:text>
	<xsl:value-of select="." />
	<xsl:text>&lt;/</xsl:text>
	<xsl:value-of select="name()" />
	<xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="@display | @placeholder | @yes | @no">
	<xsl:param name="path" required="yes" />
	<xsl:variable name="path" select="concat($path, '/@', local-name())" />
	<xsl:value-of select="$path" />
	<xsl:text>: </xsl:text>
	<xsl:value-of select="." />
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="@*" />

</xsl:stylesheet>