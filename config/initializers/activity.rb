Activity.database.create_collection :activities,
  capped: true,
  max:    200_000,
  size:   20.megabytes
