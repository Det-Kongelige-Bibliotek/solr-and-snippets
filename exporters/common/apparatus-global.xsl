<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="t"
    version="2.0">

  <xsl:param name="use_marker" select="'no'"/>

  <xsl:variable name="witnesses">
    <xsl:copy-of select="/t:TEI//t:sourceDesc/t:listWit/*"/>
  </xsl:variable>

  <xsl:variable name="grenditions">
    <xsl:copy-of select="/t:TEI//t:tagsDecl/*"/>
  </xsl:variable>

  <xsl:template mode="text" match="t:corr">
    <span title="rættelse">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:corr">
    <span title="rættelse">
      <xsl:call-template name="add_id"/>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:if test="@wit">
	<xsl:call-template name="witness">
	  <xsl:with-param name="wit" select="@wit"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@resp">
	<xsl:text>
	</xsl:text>
	<xsl:call-template name="witness">
	  <xsl:with-param name="wit" select="@resp"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@evidence">
	[<xsl:value-of select="@evidence"/>]
      </xsl:if>
    </span>
  </xsl:template>


  <xsl:template match="t:add">
    <span title="tillæg">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:del">
    <del title="sletning">
      <xsl:call-template name="render_stuff"/>
      <xsl:apply-templates/>
    </del>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:add|t:del">
    <span title="{local-name(.)}">
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates  mode="apparatus"/>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
    </span>
  </xsl:template>

  <xsl:template match="t:supplied"><span title="Supplering"><xsl:call-template name="add_id"/>[<xsl:apply-templates/>]</span></xsl:template>
  <xsl:template match="t:unclear"><span title="unclear"><xsl:call-template name="add_id"/><xsl:apply-templates/></span></xsl:template>
  <xsl:template mode="apparatus" match="t:unclear"><span title="unclear">&lt;<xsl:apply-templates/>&gt;</span></xsl:template>

  <xsl:template match="t:choice[t:reg and t:orig]">
    <span>
      <xsl:attribute name="title">
	oprindelig: <xsl:value-of select="t:orig"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:reg"/>
    </span>
  </xsl:template>

  <xsl:template match="t:choice[t:abbr and t:expan]">
    <xsl:element name="a">
      <xsl:attribute name="title">
	<xsl:for-each select="t:expan">
	<xsl:value-of select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
	</xsl:for-each>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:abbr"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:ref[@type='commentary']">
    <xsl:element name="a">
      <xsl:call-template name="add_id"/>
      <xsl:if test="@type='commentary'"><xsl:attribute name="title">Kommentar</xsl:attribute></xsl:if>
      <xsl:if test="@target">
	<xsl:attribute name="href">
	  <xsl:call-template name="make-href"/>
	</xsl:attribute>
      </xsl:if>
      &#9658; <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:note">
    <xsl:choose>
      <xsl:when test="@type='commentary'">
	<xsl:element name="p">
	  <xsl:call-template name="add_id"/>
	  <xsl:apply-templates select="t:label"/><xsl:text>: </xsl:text><xsl:apply-templates mode="note_body" select="t:p"/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="inline_note"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="note_body" match="t:p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="add_id_empty_elem">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
	<xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="render_stuff"/>
  </xsl:template>

  <xsl:template name="render_before_after">
    <xsl:param name="scope" select="'before'"/>
    <xsl:param name="rendit" select="./@rendition"/>
    <xsl:if test="$rendit">
      <xsl:for-each select="fn:tokenize($rendit,'\s+')">
	<xsl:variable name="rend" select="substring-after(.,'#')"/> 
	<xsl:for-each select="$grenditions/t:rendition[@xml:id = $rend][@scope=$scope]">
	  <em>
	    <xsl:value-of select="fn:replace(.,'^.*&quot;(.*?)&quot;.*$','$1')"/>
	  </em>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render_stuff">
    <xsl:if test="contains(@rendition,'#')">
      <xsl:variable name="rend" select="substring-after(@rendition,'#')"/>  
      <xsl:choose>
	<xsl:when test="$rend = 'capiTyp'"><xsl:attribute name="style">font-variant: small-caps;</xsl:attribute></xsl:when>
	<xsl:when test="$rend = 'spa'"><xsl:attribute name="style">font-style: italic;</xsl:attribute></xsl:when>
	<xsl:when test="/t:TEI//t:rendition[@scheme='css'][@xml:id = $rend]">
	  <xsl:attribute name="style">
	    <xsl:value-of select="/t:TEI//t:rendition[@scheme='css'][@xml:id = $rend]"/>
	  </xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">
	    <xsl:value-of select="substring-after(@rendition,'#')"/> 
	  </xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:milestone">
    <xsl:call-template name="witness">
      <xsl:with-param name="wit" select="@edRef"/>
    </xsl:call-template>
    <xsl:value-of select="@n"/>
    <xsl:text> 
    </xsl:text>
  </xsl:template>

  <xsl:template  mode="apparatus" match="t:witStart">
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
  </xsl:template>

  <xsl:template  mode="apparatus" match="t:witEnd">
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">after</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="t:witDetail">
    <!-- em>
      <xsl:comment> detail </xsl:comment>
      <xsl:apply-templates/>
    </em -->
  </xsl:template>

  <xsl:template mode="apparatus" match="t:witDetail">
    <xsl:variable name="witness"><xsl:value-of select="normalize-space(substring-after(@wit,'#'))"/></xsl:variable>
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">before</xsl:with-param>
    </xsl:call-template>
    <xsl:element name="span">
      <xsl:attribute name="title">
	<xsl:value-of select="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"/>
      </xsl:attribute>
      <em><xsl:apply-templates/> <xsl:comment> witness detail </xsl:comment></em>
      <xsl:value-of select="@n"/>
    </xsl:element>
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">after</xsl:with-param>
    </xsl:call-template>
    <xsl:text>
    </xsl:text>
  </xsl:template>


  <xsl:template mode="text" match="t:lem">
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:lem">
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates mode="apparatus"/> <xsl:text> ] </xsl:text>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:choose>
	<xsl:when test="@wit">
	  <xsl:call-template name="witness"/>
	</xsl:when>
	<xsl:when test="@resp">
	  <xsl:call-template name="witness">
	    <xsl:with-param name="wit" select="@resp"/>
	  </xsl:call-template>
	</xsl:when>
      </xsl:choose>
      <xsl:text> 
      </xsl:text>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:rdgGrp"> 
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:if test="@rendition = '#semiko'">; </xsl:if><xsl:apply-templates/><xsl:comment> rdg grp </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:app">
    <xsl:apply-templates mode="text" select="t:lem"/> 
    <xsl:element name="span">
      <xsl:call-template name="apparatus-marker"><xsl:with-param name="marker">&#128712; </xsl:with-param></xsl:call-template>
    </xsl:element>

    <span style="background-color:Aquamarine;display:none;">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates mode="apparatus" select="t:lem"/>
      <xsl:for-each select="t:rdg|t:rdgGrp|t:corr|t:note">
	<xsl:apply-templates mode="apparatus"  select="."/><xsl:if test="position() &lt; last()"><xsl:comment> ; </xsl:comment></xsl:if>
      </xsl:for-each><xsl:comment> <xsl:text> </xsl:text> app </xsl:comment>
    </span>

  </xsl:template>

  <xsl:template mode="apparatus" match="t:note">
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">before</xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">after</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="apparatus-marker">
    <xsl:param name="marker" select="'missing marker'"/>
    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-;.','___')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('apparatus',$idstring)"/>
    </xsl:variable>
    <xsl:attribute name="style">text-indent: 0;</xsl:attribute>
    <script>
      var <xsl:value-of select="concat('disp',$idstring)"/>="none";
      function <xsl:value-of select="$note"/>() {
      var ele = document.getElementById("<xsl:value-of select="@xml:id"/>");
      if(<xsl:value-of select="concat('disp',$idstring)"/>=="none") {
      ele.style.display="inline";
      <xsl:value-of select="concat('disp',$idstring)"/>="inline";
      } else {
      ele.style.display="none";
      <xsl:value-of select="concat('disp',$idstring)"/>="none";
      }
      }
    </script>
    <xsl:element name="a">
      <xsl:attribute name="title">Tekstkritik</xsl:attribute>
      <xsl:attribute name="onclick"><xsl:value-of select="$note"/>();</xsl:attribute>
      <xsl:choose>
	<xsl:when test="$use_marker='yes'  and $marker">
	  <xsl:value-of select="$marker"/>
	</xsl:when>
	<xsl:otherwise>
	  <i class="fa fa-info-circle" aria-hidden="true"><xsl:comment> * </xsl:comment></i> 
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:sic">
    <xsl:apply-templates/> [<em>sic!</em>]
  </xsl:template>

  <xsl:template mode="apparatus"  match="t:sic">
     <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
  </xsl:template>


  <xsl:template  mode="apparatus"  match="t:rdg">
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:element name="span">
	<xsl:if test="@wit">
	  <xsl:call-template name="witness"/>
	</xsl:if>
	<xsl:if test="@resp">
	  <xsl:call-template name="witness">
	    <xsl:with-param name="wit" select="@resp"/>
	  </xsl:call-template>
	</xsl:if>
	<xsl:apply-templates  mode="apparatus" />
	<xsl:if test="@evidence">
	  [<xsl:value-of select="@evidence"/>]
	</xsl:if>
	<xsl:call-template name="render_before_after">
	  <xsl:with-param name="scope">after</xsl:with-param>
	</xsl:call-template>
	<xsl:comment> rdg </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template  mode="text"  match="t:rdg">
    <xsl:element name="span">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template name="witness">
    <xsl:param name="wit" select="@wit"/>
    <xsl:comment> Witness <xsl:value-of select="$wit"/> </xsl:comment>

      <xsl:for-each select="fn:tokenize($wit,'\s+')">
	<xsl:variable name="witness"><xsl:choose><xsl:when test="contains(.,'#')"><xsl:value-of select="normalize-space(substring-after(.,'#'))"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:if test="$witnesses//t:witness[@xml:id=$witness]">
	  <xsl:element name="em">
	    <xsl:attribute name="title">
	      <xsl:value-of select="$witnesses//t:witness[@xml:id=$witness]"/>
	    </xsl:attribute>
	    <xsl:value-of select="$witness"/><xsl:choose>
	    <xsl:when test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:when></xsl:choose><xsl:comment> witness </xsl:comment>
	  </xsl:element>
	  <xsl:text>
	  </xsl:text>
	</xsl:if>
      </xsl:for-each>

  </xsl:template>


</xsl:stylesheet>