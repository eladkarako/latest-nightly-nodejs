"use strict";

const  FS           = require("fs")
      ,PATH         = require("path")
      ,URL          = require("url")
      ,HTTPS        = require("https")
      ,URL_BASE     = "https://nodejs.org/download/nightly"
      ,URL_VERINFO  = URL_BASE + "/index.json"
      ,HEADERS      = {"DNT":             "1"
                      ,"Accept":          "*/*"
                      ,"Referer":         URL_VERINFO
                      ,"Connection":      "Close"
                      ,"User-Agent":      "Mozilla/5.0 Chrome"
                      ,"Accept-Language": "en-US,en;q=0.9"
                      ,"Cache-Control":   "no-cache"
                      ,"Pragma":          "no-cache"
                      ,"X-Hello":         "Goodbye"
                      }
      ;

function get(url, onresponse, onheaders){ //supports both headers and request body handling.
  url = URL.parse(url);
  
  const CONF = {protocol: url.protocol               // "http:"
               ,auth:     url.auth                   // "username:password"
               ,hostname: url.hostname               // "www.example.com"
               ,port:     url.port                   // 80
               ,path:     url.path                   // "/"
               ,family:   4                          // IPv4
               ,method:   "GET"
               ,headers:  HEADERS
               ,agent:    undefined                  //use http.globalAgent for this host and port.
               ,timeout:  10 * 1000                  //10 seconds
               }
       ,REQUEST = HTTPS.request(CONF)
       ,CONTENT = []
       ;
  REQUEST.setSocketKeepAlive(false);                                      //make sure to return right away (single connection mode).
  REQUEST.on("response", function(response){
    if("function" === typeof onheaders) onheaders(REQUEST,response,URL,CONTENT.join("")); //response headers.
    if("function" === typeof onresponse){
      response.setEncoding("utf8");
      response.on("data", function(chunk){ CONTENT.push(chunk);                                  } );  
      response.on("end",  function(){      onresponse(CONTENT.join(""), URL, REQUEST, response); } );  //response body.
    }
  });

  REQUEST.end();
}


function natural_compare(a, b){
  var ax=[], bx=[];
  
  a.replace(/(\d+)|(\D+)/g, function(_, $1, $2){ ax.push([$1 || Infinity, $2 || ""]); });
  b.replace(/(\d+)|(\D+)/g, function(_, $1, $2){ bx.push([$1 || Infinity, $2 || ""]); });

  while(ax.length > 0 && bx.length > 0){
    var an, bn, nn;
    
    an = ax.shift();
    bn = bx.shift();
    nn = (an[0] - bn[0]) || an[1].localeCompare(bn[1]);
    if(nn) return nn;
  }
  return ax.length - bx.length;
}


function natural_compare_custom__by_version(a, b){
  a = a.version;
  b = b.version;
  return natural_compare(a, b);
}


function natural_compare_custom__by_date(a, b){
  a = a.date;
  b = b.date;
  return natural_compare(a, b);
}


console.error("getting information about all versions from " + URL_VERINFO);


get(URL_VERINFO, function(content){

  try{content = JSON.parse(content);}
  catch(err){content=null;}
  if(null===content){console.error("could not parse the \'index.json\'"); process.exitCode=1; process.exit();}
  
  //nodejs maintains few versions (currently both v10 and v12), 
  //the following part keeps the most date-recent items (mostly single v10, few v12).
  content = content.sort(natural_compare_custom__by_date)       //sort by date. most date-recent are the last items.
                   .reverse()                                   //reorder items, last to first.
                   .slice(0,3)                                  //keep 3 first items (most date-recent).
                   ;

  console.error("keeping 3 most date-recent items (mostly single v10 and few v12).");
  console.error(JSON.stringify(content, null, 2));
  console.error("\r\n\r\n");
  
  console.error("keeping single version-recent item (most date/version recent - usually v12).");
  content = content.sort(natural_compare_custom__by_version)    //sort by version, most version-recent are the last items.
                   .reverse()                                   //reorder items, last to first.
                   .slice(0,1)                                  //explicitly keep first-item (most version-recent).
                   .shift()                                     //explicit strip-away single-cell array.
                   
  console.error(JSON.stringify(content, null, 2));
  console.error("\r\n\r\n");


//--------------------------------------------
  console.log(content.version);
//--------------------------------------------
  var log = [];
  log.push("\r\n");
  log.push("Version:  " + content.version);
  log.push("Base URL: " + URL_BASE);
  log.push("Developer (source, lib, pdb, headers):");
  log.push("--------------------------------------------------");
  log.push(URL_BASE + "/" + content.version + "/" + "node-" + content.version + ".tar.xz");
  log.push(URL_BASE + "/" + content.version + "/" + "win-x86/node.lib");
  log.push(URL_BASE + "/" + content.version + "/" + "win-x86/node_pdb.7z");
  log.push(URL_BASE + "/" + content.version + "/" + "node-" + content.version + "-headers.tar.xz");
  log.push("Program (installer, portable, portable single-exe):");
  log.push("--------------------------------------------------");
  log.push(URL_BASE + "/" + content.version + "/" + "node-" + content.version + "-x86.msi");
  log.push(URL_BASE + "/" + content.version + "/" + "node-" + content.version + "-win-x86.7z");
  log.push(URL_BASE + "/" + content.version + "/" + "win-x86/node.exe");
  log.push("\r\n");
  log = log.join("\r\n");

  console.error(log);
  FS.writeFileSync("log.txt", log, {flag:"w", encoding:"utf8"});

  console.error(log);

  process.exitCode=0;
  process.exit();
});

