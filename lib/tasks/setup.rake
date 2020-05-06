require 'csv'

task :setup => [
  :import_parliaments,
  :import_sessions,
  :populate_dissolution_periods,
  :populate_prorogation_periods,
  :import_houses,
  :populate_calendar_dates
]

task :import_parliaments => :environment do
  puts "importing parliaments"
  CSV.foreach( 'db/data/parliaments.csv' ) do |row|
    parliament_period = ParliamentPeriod.new
    parliament_period.number = row[0]
    parliament_period.start_on = row[2].to_date
    parliament_period.end_on = row[4].to_date if row[4]
    parliament_period.save
  end
end
task :import_sessions => :environment do
  puts "importing sessions"
  CSV.foreach( 'db/data/sessions.csv' ) do |row|
    session = Session.new
    session.number = row[1]
    session.start_on = row[2].to_date
    session.end_on = row[3].to_date if row[3]
    parliament_period = ParliamentPeriod.find_by number: row[0]
    session.parliament_period = parliament_period
    session.save
  end
end
task :populate_dissolution_periods => :environment do
  puts "populating dissolution periods from parliament periods"
  parliament_periods = ParliamentPeriod.all.where( 'end_on is not null' ).order( 'start_on' )
  parliament_periods.each do |parliament_period|
    dissolution_period = DissolutionPeriod.new
    dissolution_period.number = parliament_period.number
    dissolution_period.start_on = parliament_period.end_on + 1.day
    dissolution_period.end_on = parliament_period.following_parliament_period.start_on - 1.day
    dissolution_period.save
  end
end
task :populate_prorogation_periods => :environment do
  puts "populating prorogation periods from sessions"
  sessions = Session.all.where( 'end_on is not null' ).order( 'start_on' )
  sessions.each do |session|
    # if there is a following session in the same parliament insert a prorogation between end of this session and start of this one
    if session.following_session_in_parliament
      prorogation_period = ProrogationPeriod.new
      prorogation_period.number = session.number
      prorogation_period.start_on = session.end_on + 1.day
      prorogation_period.end_on = session.following_session_in_parliament.start_on - 1.day
      prorogation_period.parliament_period = session.parliament_period
      prorogation_period.save
    # If there's no following session in the same parliament but this session ends before parliament ends insert a prorogation between end of this session and end of parliament
    elsif session.end_on < session.parliament_period.end_on
      prorogation_period = ProrogationPeriod.new
      prorogation_period.number = session.number
      prorogation_period.start_on = session.end_on + 1.day
      prorogation_period.end_on = session.parliament_period.end_on
      prorogation_period.parliament_period = session.parliament_period
      prorogation_period.save
    end
  end
end
task :import_houses => :environment do
  puts "importing houses"
  CSV.foreach( 'db/data/houses.csv' ) do |row|
    house = House.new
    house.name = row[0]
    house.save
  end
end
task :populate_calendar_dates => :environment do
  puts "populating dates"
  (Date.new(2020, 01, 01)..Date.new(2022, 01, 01)).each do |date|
    calendar_date = CalendarDate.new
    calendar_date.date = date
    calendar_date.save
  end
end