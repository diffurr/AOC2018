fetch("input.txt")
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
    var result = 0;
    var results = new Set;
    var numbers = data.split("\n");
    numbers.pop();
    results.add(result);
    for (i = 0;;i = (i + 1) % numbers.length) {
      result += parseInt(numbers[i]);
      if (results.has(result)) {
        break;
      }
      else {
        results.add(result);
      }
    }

    document.getElementById("answer").innerHTML = result;
  })