#= require ../stack
#= require ./weekends

class App.Controllers.Musos.Roster extends App.Controllers.Stack
  first: App.Controllers.Musos.Weekends
  