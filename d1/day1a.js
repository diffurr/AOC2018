fetch("input.txt")
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
    var result = 0;
    var strings = data.split("\n");
    strings.pop();
    for (i in strings) {
      result += parseInt(strings[i], 10);
    }
    document.getElementById("answer").innerHTML = result;
  })