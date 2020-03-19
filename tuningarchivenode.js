//Globals
messages = [];
killswitch = false;

//Requires
fs = require("fs");
http = require("http");

//Save to file
saveBackup = function(data, filename) {
  if(!data) {
    console.error("saveBackup: No data");
    return;
  }

  if(!filename)
    filename = "backup_"+Date.now()+".json";

  if(typeof data === "object") {
    data = JSON.stringify(data, undefined, 4);
  }

  fs.writeFileSync(filename, data);
}

function msgurl(groupname, n){
  return "http://groups.yahoo.com/api/v1/groups/"+groupname+"/messages/"+n+"/raw";
}

function requestSingleMessage(groupname, i, start, end, delay) {
  http.get(msgurl(groupname,i), function(res) {
    var rawData = "";
    res.on("data", function(chunk){rawData += chunk;});
    res.on("end", function() {
      try {
        const parsedData = JSON.parse(rawData);
        parseSingleMessage(rawData, groupname, i, start, end, delay);
      }
      catch (e) {
        console.error(e.message);
      }
    });
  });
}

function parseSingleMessage(rawData, groupname, i, start, end, delay) {
  //Try parsing the result as JSON -- if the result isn't valid, we may have an error
  try {
    messages[i-start] = JSON.parse(rawData);
  }
  catch (e) {
    console.log("JSON parse failed - you've possibly been throttled. Halting");
    saveBackup(messages,"yahoo_"+ groupname +"_messages_api_raw_"+start+"-"+(i-1)+"_"+Date.now()+".json");
		keepreading = false;
	}

  //Check to make sure Yahoo hasn't returned an error
  if(!messages[i-start].ygError) {
    console.log("Got message " + i);
    messages[i-start] = messages[i-start].ygData;
    console.log("Message snippet:\n" + messages[i-start].msgSnippet + "\n");  //don't remember what this is
  }
  else {
    console.log("Error at message " + i + "!");
    messages[i-start] = messages[i-start].ygError;
    console.log("Error message:\n" + messages[i-start].errorMessage + "\n");
  }

	if(i < end && !killswitch) {
		setTimeout(function(){requestSingleMessage(groupname, i+1, start, end, delay)}, delay);
	}
  else {
    console.log("Finished!");
    saveBackup(messages,"yahoo_"+ groupname +"_messages_api_raw_"+start+"-"+i+"_"+Date.now()+".json");
    return messages;
  }
}

function getMessages(groupname, start, end, delay) {
	requestSingleMessage(groupname, start, start, end, delay);
}
