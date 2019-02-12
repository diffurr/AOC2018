  Param = {
    ID: 0,
    X: 1,
    Y: 2,
    W: 3,
    H: 4,
  };

  fetch("input.txt")
  .then(function(response) {
    return response.text();
  })
  .then(function(data) {
  console.time("timer");
    var Fabric = make2dArray(1000, 0);
    console.timeEnd("timer");
    var ids = data.split("\n");
    var re = /\d+/g;

    for (var i in ids) {
      var claim = ids[i].match(re);
      cut(Fabric, claim);
    }
    
    var answer = Fabric.reduce(function(a, b) {
      return a + b.reduce(function(a, b) {
        if (b < 0) {
          return a + 1;
        }
        else {
          return a + 0;
        }
      }, 0)
    }, 0)

    document.getElementById("answer").innerText = answer;
  })

  function cut(fabric, claim) {
    var id = parseInt(claim[Param.ID]);
    var x = parseInt(claim[Param.X]);
    var y = parseInt(claim[Param.Y]);
    var w = parseInt(claim[Param.W]);
    var h = parseInt(claim[Param.H]);

    for (var i = y; i < (y + h); i++) {
      for (var j = x; j < (x + w); j++) {
        if (fabric[i][j] === 0) fabric[i][j] = id;
        else fabric[i][j] = -1;
      }
    }
  }

  function make2dArray(dim, init) {
    var arr = [];
    for (var i = 0; i < dim; i++) {
      arr.push(Array.apply(null, Array(dim)).map(function(x) { return init}));
    }
    return arr;
  }

  function showFabric(fabric) {
    var text = "";
    for (var i = 0; i < fabric.length; i++) {
      text += fabric[i].join("");
      text += "\n";
    }
    return text;
  }