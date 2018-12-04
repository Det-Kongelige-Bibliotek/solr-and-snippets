<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t fn">

  <xsl:import href="../solrize-global.xsl"/>
  <xsl:param name="subcollection" select="'sks'"/>  

  <xsl:param name="is_monograph">yes</xsl:param>

  <xsl:param name="volume_title">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@level='s']">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="worktitle">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[not(@level) and not(@type)]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:editor">
      <xsl:for-each select="t:name">
	<xsl:value-of  select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="publisher" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:authority">
      <xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@level='s']">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:template match="/">
    <xsl:element name="add">
      <xsl:call-template name="generate_volume_doc" >
	<xsl:with-param name="cat">volume</xsl:with-param>
	<xsl:with-param name="type" select="'trunk'"/>
	<xsl:with-param name="is_monograph" select="'yes'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="facs_and_text">
    <field name="has_facs_ssi">no</field>
    <field name="has_text_ssi">yes</field>
  </xsl:template>

  <xsl:template name="get_category">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-txt-')">work</xsl:when>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-txr-')">editorial</xsl:when>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-kom-')">editorial</xsl:when>
    </xsl:choose>
    </xsl:template>

  <xsl:template match="t:text[not(@decls) and not(ancestor::node()[@decls])]">

    <xsl:comment> work: <xsl:value-of select="$worktitle"/></xsl:comment>
    <xsl:comment> volume/series: <xsl:value-of select="$volume_title"/></xsl:comment>
    <xsl:comment> matching t:text without @decls </xsl:comment>

    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$worktitle"/>
      <xsl:with-param name="category">
	<xsl:call-template name="get_category"/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="t:div[not(@decls) and  not(ancestor::node()[@decls])]">

    <xsl:comment><xsl:value-of select="$worktitle"/></xsl:comment>
    <xsl:comment><xsl:value-of select="$volume_title"/></xsl:comment>
    <xsl:comment> matching t:div without @decls </xsl:comment>

    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$worktitle"/>
      <xsl:with-param name="category">
	<xsl:if test="local-name(.) = 'text' and contains($path,'-txt-')">work</xsl:if>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:comment> you want to go deeper </xsl:comment>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template name="text_type">
    <xsl:if test="@subtype">
      <xsl:element name="field">
	<xsl:attribute name="name">text_type_ssi</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="@subtype='journalsAndPapers'">Journaler og papierer</xsl:when>
	  <xsl:when test="@subtype='publishedWritings'">Trykte skrifter</xsl:when>
	  <xsl:when test="@subtype='lettersAndDedications'">Breve og dedikationer</xsl:when>
	  <xsl:when test="@subtype='unpublishedWritings'">Utrykte skrifter</xsl:when>
	  <xsl:when test="@subtype='documents'">Dokumenter</xsl:when>
	</xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="extract_titles_authors_etc">
    <xsl:choose>
      <xsl:when test="contains($path,'-txt')">
	<xsl:element name="field"><xsl:attribute name="name">author_name_ssi</xsl:attribute>Kierkegaard, Søren</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_name_ssim</xsl:attribute>Kierkegaard, Søren</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_nasim</xsl:attribute>Søren Kierkegaard</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>Søren Kierkegaard</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:author">
	  <xsl:for-each select="t:name">
	    <xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>
	    <xsl:value-of  select="."/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="field"><xsl:attribute name="name">publisher_tesim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_nasim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>

  </xsl:template>

  <xsl:template mode="backtrack" match="node()[@xml:id]">
    <xsl:element name="field">
      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
      <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',@xml:id)"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ancestor::node()">
	<xsl:apply-templates mode="backtrack" select="ancestor::t:div[1]|ancestor::t:text[1]"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="field">
	  <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	  <xsl:value-of select="$path"/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="what_i_can"/>

</xsl:transform>