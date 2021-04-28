<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk

-->
<xsl:transform version="2.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="targetOp" select="''"/>
  <xsl:param name="hostname" select="''"/>

  <xsl:output encoding="UTF-8"
	      indent="yes"
	      method="xml"
	      omit-xml-declaration="yes"/>

  <xsl:template match="/t:TEI">
    <div>
      <xsl:apply-templates mode="get_lists" select="./t:text"/>
    </div>
  </xsl:template>

  <xsl:template match="t:teiHeader"/>

  <xsl:template  mode="get_lists" match="*"></xsl:template>
  
  <xsl:template  mode="get_lists" match="t:group|t:body|t:text|t:div|t:lg|t:front|t:back">
    <xsl:comment> get lists </xsl:comment>
    <xsl:comment>
      <xsl:value-of select="$path"/><xsl:text>
</xsl:text>      <xsl:value-of select="t:head"/>
    </xsl:comment>
    <xsl:if test="@decls|./t:head|.//t:group|.//t:body|.//t:text|.//t:div|.//t:front|.//t:back">
      <ul>
        <xsl:attribute name="id">
	  <xsl:value-of select="concat('list-',@xml:id)"/>
        </xsl:attribute>
        <xsl:call-template name="get_item"/>
      </ul>
    </xsl:if>
  </xsl:template>
                                       
  <xsl:template name="get_item">
    <xsl:comment> get_item </xsl:comment>
    <xsl:element name="li">
      <xsl:attribute name="id">
	<xsl:value-of select="concat('item-',@xml:id)"/>
      </xsl:attribute>
      <xsl:call-template name="add_anchor"/>
      <xsl:apply-templates mode="get_lists"/> 
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:head">
    <xsl:apply-templates/><xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="t:lb">
    <xsl:text> 
    </xsl:text>
  </xsl:template>

  <xsl:template match="t:hi">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="add_anchor">
    <xsl:variable name="bibl">
      <xsl:choose>
	<xsl:when test="contains(@decls,'#')"><xsl:value-of select="substring-after(@decls,'#')"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="@decls"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
	<xsl:when 
	    test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]">
	  <xsl:value-of
	      select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]"/>
	</xsl:when>
	<xsl:when test="t:head[text()]">
          <xsl:for-each select="t:head[text()]">
	    <xsl:apply-templates select="."/><xsl:text>  </xsl:text>
          </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="some_text">
	    <xsl:call-template name="some_text"/>
	  </xsl:variable>
	  <xsl:value-of
	      select="substring(normalize-space($some_text/string()),1,30)"/>
	  <xsl:if test="string-length(normalize-space($some_text/string())) &gt; 30"><xsl:text>...</xsl:text></xsl:if>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length(normalize-space($title)) &gt; 0">
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:call-template name="make_href"/>
	</xsl:attribute>
	<xsl:value-of select="$title"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make_href">
    <xsl:if test="@xml:id">
      <xsl:choose>
        <xsl:when test="@decls"><xsl:value-of select="concat('/text/',fn:replace($path,'(^.*)((sh)|(r))oot.*$','$1shoot-'),@xml:id)"/></xsl:when>
        <xsl:otherwise>
	  <xsl:choose>
	    <xsl:when test="./ancestor::node()[@decls]"><xsl:value-of select="concat('/text/',fn:replace($path,'(^.*)((sh)|(r))oot.*$','$1shoot-'),./ancestor::node()[@decls][1]/@xml:id,'#',@xml:id)"/></xsl:when>
	    <xsl:otherwise><xsl:value-of select="concat('/text/',fn:replace($path,'(^.*)((sh)|(r))oot.*$','$1root#'),@xml:id)"/></xsl:otherwise>
	  </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  
  <xsl:template name="some_text">
    <xsl:variable name="head_text">
      <xsl:for-each select=".//t:head[1]">
        <xsl:apply-templates  mode="collect_text" select="."/><xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($head_text) &gt; 5">
        <xsl:value-of select="$head_text"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select=".//text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="collect_text" match="t:app">
    <xsl:apply-templates  mode="collect_text" select="t:lem/text()"/> 
  </xsl:template>

  
</xsl:transform>

