dnl <!-- $Csoft: fanatic.m4,v 1.15 2002/07/31 02:48:03 vedge Exp $ -->
dnl vim:syn=html
changequote([,])
define(ICON, [<a href="$1"><img src="http://vedge.com.ar/pic/i_$2.png" alt="$3" border="0" width="32" height="32"></a>])
define(RCSID, [define(_RCSID_, [<p align="right" class="rcsid"><i>$1</i></p>])])
include(_BASE_/base.htm)
<html>
<head>
<title> _TITLE_ </title>
<style>
BODY, P, TD, ADDRESS { 
  font-family: lucida, verdana;
  font-size: 12pt;
}
H1 {
  font-size: 18pt;
  color: #ffee88;
}
H1.super {
  font-size: 24pt;
  color: #ffcc00;
  font-weight: bold;
  font-style: italic;
  text-align: center;
}
P.rcsid {
  font-size: 10pt;
}
P.title {
  font-size: 18pt;
  color: #ffcc00;
  font-weight: bold;
  font-style: italic;
}
UL,OL,LI {
  font-size: 14pt;
  color: #ffffff;
}
BLOCKQUOTE {
  font-size: 14pt;
  color: #c0c0c0;
}
</style>
</head>
<body bgcolor="#ffffff" text="#c0c0c0" link="#d6f0ff" alink="#d1ecff" vlink="#d1ecff" background="http://vedge.com.ar/video/relb1.jpg"><br>
<center>
<table border="0" width="90%" height="90%" cellspacing="0" cellpadding="6">
 <tr>
  <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) valign="top">
   &nbsp;
  </td>
  ifelse(_IMAGE_, none, [], [
   <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) width="45%"
    valign="top">
    <p class="title">(_TITLE_)</p>
   </td>
  ])
  <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) width="45%"
   valign="top">
   &nbsp;
  </td>
  <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) valign="top">
  </td>
  <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) width="10%"
   valign="top">
   &nbsp;
  </td>
 </tr>
 <tr>
  <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) valign="middle">
   &nbsp;
  </td>
  ifelse(_IMAGE_, none, [], [
   <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) width="45%"
    valign="middle">
     <img src="_IMAGE_" alt="">
   </td>
  ])
  <td ifelse(_TRANSPARENT_, yes, [], [bgcolor="#000000"]) width="45%"
   valign="middle">
   _CONTENT_
  </td>
  <td>
   &nbsp;
  </td>
  <td bgcolor="#000000" width="10%">
   <center>
   <a href="BASEURL">maison</a><br>
   .<br>
   <a href="BASEURL/cook">cuisine</a><br>
   .<br>
   <a href="BASEURL/video">videos</a><br>
   .<br>
   <a href="BASEURL/luc">luc</a><br>
   .<br>
   <a href="BASEURL/vieux.html">vieux</a><br>
   </center>
  </td>
 </tr>
</table>
<br>
<table border="0" bgcolor="#000000" width="90%" height="5%" cellspacing="0"
 cellpadding="6">
 <tr>
  <td bgcolor="#000000">
   _RCSID_
  </td>
 </tr>
</table>
</center>
</body>
</html>
