fetch("input.txt")
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
    var ids = data.split("\n");
    var two = 0, three = 0;
    for (i in ids) {
      let str = ids[i];
      if (repeatedChars(str, 2)) two++;
      if (repeatedChars(str, 3)) three++;
    } 

    document.getElementById("answer").innerHTML = two * three;
  })

function repeatedChars(string, repeat) {
  var chars = string.split("");
  chars.sort();
  var char = chars[0]
  var count = 1;
  for (i = 1; i < chars.length; i++) {
    if (chars[i] === char) count++;
    else {
      if (count === repeat) return true;
      count = 1;
      char = chars[i];
    }
  }
  if (count === repeat) return true;
  else return false;
}