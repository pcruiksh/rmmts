# Data to render points pie chart

json.array! @house.mates do |mate|
  json.value mate.points.sum(:amount).to_i
  json.label mate.first_name
end
