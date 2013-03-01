#= require ../stack
#= require ./weekends

class App.Controllers.Availability.Availability extends App.Controllers.Stack
  first: App.Controllers.Availability.Weekends
