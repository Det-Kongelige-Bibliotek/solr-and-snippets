<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t fn">
  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="./apparatus.xsl"/>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />
  <xsl:variable name="iip_baseuri"  select="'http://kb-images.kb.dk/public/sks/'"/>
  <xsl:variable name="iiif_suffix" select="'/full/full/0/native.jpg'"/>

  <xsl:template match="t:pb">
    <xsl:element name="span">
      <xsl:if test="not(@edRef)">
	<xsl:attribute name="class">pageBreak</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="add_id"/>
	<xsl:choose>
	  <xsl:when test="@n and not(@edRef)"><a><small><xsl:value-of select="@n"/></small></a></xsl:when>
	  <xsl:otherwise>
	    <xsl:text><!-- an invisible anchor --></xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="print_date">
    <xsl:param name="date" select="''"/>
    <xsl:variable name="year">
      <xsl:value-of select="substring($date,1,4)"/>
    </xsl:variable>
    <xsl:variable name="month_day">
      <xsl:choose>
      <xsl:when test="not(contains($date,'0000'))"><xsl:value-of select="substring-after($date,$year)"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
      date = <xsl:value-of select="$date"/>

      month_day = <xsl:value-of select="$month_day"/>

      year = <xsl:value-of select="$year"/>

      month = <xsl:value-of select="substring($month_day,1,2)"/>

      day   = <xsl:value-of select="substring($month_day,3,4)"/>

    -->
    <xsl:value-of select="$year"/><xsl:if test="not(contains($date,'0000'))"> &#8211; <xsl:value-of select="substring($month_day,1,2)"/> &#8211; <xsl:value-of select="substring($month_day,3,4)"/></xsl:if>
  </xsl:template>



  <xsl:template match="t:rdgGrp"> 
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:if test="@rendition = '#semiko'">; </xsl:if><xsl:apply-templates/><xsl:comment> rdg grp </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:app">
    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-;.','___')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('apparatus',$idstring)"/>
    </xsl:variable>
    <xsl:apply-templates select="t:lem"/>
    <xsl:element name="sup">
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
	<i class="fa fa-info-circle" aria-hidden="true"><xsl:comment> * </xsl:comment></i>
      </xsl:element>
    </xsl:element>
    <span style="background-color:Aquamarine;display:none;">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:rdg|t:rdgGrp|t:corr"/>
    </span>
  </xsl:template>

  <xsl:template match="t:sic">
  </xsl:template>

  <xsl:template match="t:rdg">
    <xsl:if test="t:sic/@rendition = '#so'"><xsl:text> Således også: </xsl:text></xsl:if>
    <xsl:element name="span">
      <xsl:if test="@wit">
	<xsl:call-template name="witness"/>
      </xsl:if><xsl:choose><xsl:when test="t:sic/@rendition = '#so'"><xsl:text> </xsl:text></xsl:when><xsl:otherwise><xsl:text>: </xsl:text></xsl:otherwise></xsl:choose>
      <xsl:apply-templates/><xsl:if test="@evidence">[<xsl:value-of select="@evidence"/>]</xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:dateline/t:date">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:call-template name="print_date"> 
	<xsl:with-param name="date" select="@when"/>
      </xsl:call-template>
    </span>
  </xsl:template>

  <xsl:template name="make-href">

    <xsl:param name="go_to" select="@target"/>

    <xsl:variable name="target">
      <xsl:value-of select="fn:lower-case($go_to)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($target,'#') and not(substring-before($target,'#'))">
	<xsl:value-of select="$target"/>	    
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="href">
	  <xsl:variable name="fragment">
	    <xsl:if test="contains($target,'#')">
	      <xsl:value-of select="concat('#',substring-after($target,'#'))"/>
	    </xsl:if>
	  </xsl:variable>
	  <xsl:variable name="file">
	    <xsl:choose>
	      <xsl:when test="contains($target,'#')">
		<xsl:value-of select="substring-before($target,'#')"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$target"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test="contains($file,'../')">
	      <xsl:value-of select="concat($c,'-',substring-before(substring-after($file,'../'),'.xml'),'-root',$fragment)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="contains($path,'-txt')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txt'),
			      '-',
			      substring-before($target,'.xml'),
			      '-root',
			      substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-kom')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-kom'),'-',substring-before($target,'.xml'),'-root',substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-txr')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txr'),'-',substring-before($target,'.xml'),'-root',substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$target"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<xsl:value-of select="concat($adl_baseuri,'/text/',translate($href,'/','-'))"/>
      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>



</xsl:transform>