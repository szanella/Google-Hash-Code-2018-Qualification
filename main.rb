require 'pry'

file = ARGV[0]

file_lines = File.read("./in/#{file}.in").split("\n")

rows, columns, fleet, rides, bonus, steps = file_lines[0].split(' ').map {|x| x.to_i}

rides_data = []

def distance r1, c1, r2, c2
  (r2 - r1).abs + (c2 - c1).abs
end

def score_ride car_pos, ride, bonus, step
  ride[:length] +
      (distance(car_pos[0], car_pos[1], ride[:r1], ride[:c1]) <= (ride[:start] - step) ? bonus : 0)
end

file_lines[1..-1].each_with_index do |line, index|
  params = line.split ' '
  rides_data.push({
                      r1: params[0].to_i,
                      c1: params[1].to_i,
                      r2: params[2].to_i,
                      c2: params[3].to_i,
                      start: params[4].to_i,
                      finish: params[5].to_i,
                      index: index,
                      length: distance(params[0].to_i, params[1].to_i, params[2].to_i, params[3].to_i),
                      taken: false
                  })
end

rides_data = rides_data.sort_by {|ride| ride[:finish]}.reverse

# puts rows
# puts columns
# puts fleet
# puts rides
# puts bonus
# puts steps
# puts rides_data

# vehicles_free_step = Array.new(fleet, 0)
#
# vehicles_positions = Array.new(fleet)
# vehicles_positions.each_index do |i|
#   vehicles_positions[i] = [0, 0]
# end
#
# vehicles_rides = Array.new(fleet)
# vehicles_rides.each_index do |i|
#   vehicles_rides[i] = []
# end

vehicles_data = []
fleet.times do |car_index|
  vehicles_data.push({
                         position: [0, 0],
                         rides: [],
                         free_step: 0,
                         index: car_index,
                         ride_distances: []
                     })
end

# rides_data.each do |ride|
#   puts score_ride [0, 0], ride, bonus, 0
# end

# car_to_ride_distances = []

# car_to_ride_scores = []

steps.times do |step|
  rides_data.each_with_index do |ride, r_index|
    if ride[:finish] < step
      rides_data.delete_at r_index
    else
      break
    end
  end

  break if rides_data.select {|ride| !ride[:taken]}.empty?

  startable_rides = rides_data.select {|ride| !ride[:taken] && (step + (rows + columns)/2 >= ride[:start])}
  puts "Step: #{step}/#{steps}.\tRemaining rides: #{rides_data.select {|ride| !ride[:taken]}.length}.\tStartable rides: #{startable_rides.count}"
  vehicles_data.select{ |vehicle| vehicle[:free_step] <= step }.sample(50).each_with_index do |vehicle|
    if vehicle[:free_step] > step
      next
    end

    best_score = 0
    chosen_ride_index = nil
    distance_from_chosen_ride = nil

    startable_rides.each_with_index do |ride, ride_index|

      unless vehicle[:distances] && vehicle[:distances][ride[:index]]
        vehicle[:distances] = [] if vehicle[:distances].nil?
        vehicle[:distances][ride[:index]] = distance(vehicle[:position][0], vehicle[:position][1], ride[:r1], ride[:c1])
      end
      next if ride[:taken] || (step + vehicle[:distances][ride[:index]] + ride[:length]) >= ride[:finish] ||
          (distance_from_chosen_ride && (distance_from_chosen_ride < vehicle[:distances][ride[:index]])) ||
          (step + vehicle[:distances][ride[:index]] < ride[:start])

      score = score_ride(vehicle[:position], ride, bonus, step)
      if score >= best_score
        best_score = score
        chosen_ride_index = ride_index
        distance_from_chosen_ride = vehicle[:distances][ride[:index]]
      end
    end


    if chosen_ride_index
      chosen_ride = startable_rides[chosen_ride_index]
      vehicle[:rides].push chosen_ride[:index]
      vehicle[:free_step] = step + distance_from_chosen_ride + chosen_ride[:length]
      vehicle[:position]= [chosen_ride[:r2], chosen_ride[:c2]]
      vehicle[:distances] = []
      # rides_data.delete_at chosen_ride_index
      chosen_ride[:taken] = true
    end
  end

  # break if all_vehicles_free && no_ride_assigned
  # puts "Loops #{loops}"
  # puts "Distances #{recomputed_distances}" if step > 41450
  # puts "Scores #{computed_scores}" if step > 41450
end

submission = vehicles_data.map do |vehicle|
  "#{vehicle[:rides].length} #{vehicle[:rides].join(' ')}"
end.join("\n")

File.write("./out/#{file}.out", submission)