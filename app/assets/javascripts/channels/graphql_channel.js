// This registry keeps track of outstanding requests
App.graphqlRegistry = {
  _requests: {},

  // Store handlers & results for `queryId`.
  // These handlers & results can be fetched by `.get(queryId)`
  register: function(queryId, onData, onErrors) {
    var entry = {
      queryId: queryId,
      onData: onData,
      onErrors: onErrors,
      didReceivePatch: false,
      data: {},
      errors: [],
    }
    this._requests[queryId] = entry
  },

  get: function(queryId) {
    return this._requests[queryId]
  },

  // Mutate `entry` 😢 by merging `patch` into it
  // TODO: make it return a new result instead
  mergePatch: function(entry, patch) {
    entry.didReceivePatch = true
    if (patch.path.length === 0) {
      entry.data = patch.value
    } else {
      var targetHash = entry.data
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
  },
}

App.graphqlChannel = App.cable.subscriptions.create({channel: "GraphqlChannel", client_id: Date.now()}, {
  connected: function() {
    $(document).trigger("graphql:ready")
  },

  // Called by server-sent events
  received: function(data) {
    console.log("received", data)
    var queryId = data.query_id
    var request = App.graphqlRegistry.get(queryId)
    if (!request) {
      // The queryId doesn't exist on this client,
      // it must be for another one of this user's tabs
    } else if (data.patch) {
      // Patch for an existing request
      App.graphqlRegistry.mergePatch(request, data.patch)
      request.onData(request.data)
      if (request.data.errors && request.data.errors.length) {
        request.onErrors(request.errors)
      }
    } else if (data.result) {
      // Whole payload, and we didn't receive any patches for this
      var result = data.result
      if (result.data) {
        request.onData(result.data)
      }
      if (result.errors) {
        request.onErrors(result.errors)
      }
    }
  },

  fetch: function(query, variables, onData, onErrors) {
    var queryId = Date.now()
    App.graphqlRegistry.register(queryId, onData, onErrors)

    console.log("sending", query, variables, queryId)
    this.perform("fetch", {
      query: query,
      variables: JSON.stringify(variables),
      query_id: queryId,
    })
  }
})
