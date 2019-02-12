fetch("input.txt")
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
    var ids = data.split("\n");
    var id1 = 0;
    var id2 = 0;
    for (let i = 0; i < ids.length - 1; i++) {
      for (let j = i + 1; j < ids.length; j++) {
        if (diffChars(ids[i], ids[j]) === 1) {
          id1 = i;
          id2 = j;
          i = j = ids.length + 1;
          break;
        }
      }
    }
    document.getElementById("answer").innerHTML = diffIds(ids[id1], ids[id2]);
  })

  function diffChars(id1, id2) {
    var count = 0;
    for (let i in id1) {
      if (id1[i] != id2[i]) count++;
    }
    return count;
  }

  function diffIds(id1, id2) {
    var common = "";
    for (let i in id1) {
      if (id1[i] == id2[i]) common += id1[i];
    }
    return common;
  }