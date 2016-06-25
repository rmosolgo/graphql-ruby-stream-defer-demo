window.GraphQLFetch = {
  // Send a GraphQL query to the server, then receive patches
  // from `\n\n`-delimited chunks.
  // For each patch, call `onData` with the updated data object
  // and/or `onErrors` with the new errors.
  // TODO: support errors :)
  fetch: function(queryString, variables, onData, onErrors) {
    var xhr = new XMLHttpRequest()
    xhr.open("POST", "/chunked_graphql")
    xhr.setRequestHeader('Content-Type', 'application/json')
    var csrfToken = $('meta[name="csrf-token"]').attr('content')
    xhr.setRequestHeader('X-CSRF-Token', csrfToken)

    // This will collect patches to publish to `onData`
    var responseData = {}

    // It seems like `onprogress` was called once with the first _two_ patches.
    // Track the index to make sure we don't miss any double-patches.
    var nextPatchIdx = 0

    var _this = this
    xhr.onprogress = function () {
      // responseText grows; we only care about the most recent patch
      var patchStrings = xhr.responseText.split("\n\n")

      while (patchStrings.length > nextPatchIdx) {
        var nextPatchString = patchStrings[nextPatchIdx]
        console.log("PATCH:", nextPatchString)
        var nextPatch = JSON.parse(nextPatchString)
        _this._mergePatch(responseData, nextPatch)
        nextPatchIdx += 1
      }

      onData(responseData)
    }

    xhr.send(JSON.stringify({
      query: queryString,
      variables: variables,
    }))
  },

  _mergePatch: function(responseData, patch) {
    if (patch.path.length === 0) {
      Object.assign(responseData, patch.value)
    } else {
      var targetHash = responseData
      var steps = patch.path.slice(0, patch.path.length - 1)
      var lastKey = patch.path[patch.path.length - 1]
      steps.forEach(function(step) {
        var nextStep = targetHash[step]
        if (nextStep == null) {
          nextStep = targetHash[step] = {}
        }
        targetHash = nextStep
      })
      targetHash[lastKey] = patch.value
    }
  }
}
