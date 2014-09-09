# Pool like simulation/inference
using Sigma
using Compose
using Color

points_to_parametric(p1,p2) = [p1 points_to_vec(p2,p1)]
points_to_parametric(edge) = points_to_parametric(edge[:,1], edge[:,2])
points_to_vec(p1, p2) = [p1[1] - p2[1], p1[2] - p2[2]]
points_to_vec(edge) = points_to_vec(edge[:,1], edge[:,2])

# Where if anywhere, along p does it interect segment
function intersect_segments(p, q)
  w = p[:,1] - q[:,1]
  u = p[:,2]
  v = q[:,2]
  (v[2] * w[1] - v[1] * w[2]) / (v[1] * u[2] - v[2] * u[1])
end

parametric_to_point(p, s) = p[:,1] + s * p[:,2]
dotty(a,b) = a[1]*b[1] + a[2]*b[2]
perp(v) = [-v[2],v[1]]
normalise(v) = v / 5.
function reflect(v,q)
  q_norm = normalise(q)
  n_amb = perp(q_norm)
  v2 = normalise(v)
  println("normal before", n_amb)
  n = @If dotty(q_norm,v2) < 0 n_amb -n_amb
  println("normal after", n)
  println("dot ", dotty(q_norm,v2))
  v2 - 2 * (dotty(v2,n) * n)
end

# is a the smallest element in list ss
function smallest(x,ys)
  println("getting here")
  issmallest =
    @If(x < 0.001, false,
        begin
        issmallest = true
          for i in 1:length(ys)
            issmallest = @If (ys[i] > 0.01) ((ys[i] >= x) & issmallest) issmallest
          end
#           println("issmallest", issmallest, " ", x, ys)
        issmallest
        end)
  issmallest
end

# function smallest(rv::RandomVariable, ra::RandomArray)
#   function(ω)
#     ys = ra(ω)
#     x = rv(ω)
#     issmallest =
#     @If(x < 0.001, false,
#         begin
#           issmallest = true
#           for i in 1:length(ys)
#             issmallest = @If (ys[i,1] > 0.01) ((ys[i,1] >= x) & issmallest) issmallest
#           end
#           #          println("issmallest", issmallest, " ", x, ys)
#           issmallest
#         end)
#   end
# end

# a = uniformArray(0,1,3,1)
# makeIndependentRandomVariables

# if its negative, it can't be the smallest
# otherwise, for all others
# its the smallest if its smaller than all the positive ones
# function bounce(srv,v1rv,v2rv,u1rv,u2rv)
#   function(ω)
#     s = srv(ω)
#     v1 = v1rv(ω)
#     v2 = v2rv(ω)
#     u1 = v1rv(ω)
#     u2 = v2rv(ω)
#     # The Obstacle
#     v_norm = sqrt(sqr(v1) + sqr(v2))
#     v1_normed = v1 / v_norm
#     v2_normed = v2 / v_norm

#     # The ray
#     u_norm = sqrt(sqr(u1) + sqr(u2))
#     u1_normed = u1 / u_norm
#     u2_normed = u2 / u_norm

#     n1 = -v2
#     n2  = v1

#     u = [u1,u2]
#     v = [v1,v2]
#     n = [n1,n2]


#     n1,n2 = @If(dotty(-u,v) < 0,
#                 -, (n1,n2))
#     v2 - 2 * (dotty(v2,n) * n)
#   end
# end

function bounce(p,s,o)
#   println("Bouncing", p, s, o)
  v = p[:,2]
  reflection = reflect(v,o[:,2])
  new_pos = p[:,1] + p[:,2] * s
  [new_pos reflection]
end

function simulate(num_steps::Integer, obs)
  obs = map(points_to_parametric, obstacles)
  num_steps = num_steps - 1
  start_pos = [4, 5]
  dir  = normalise([rand()*2-1,rand()*2-1])
#   dir = [uniform(1,-1,1),uniform(2,-1,1)]
  pos_parametric = Array(Any, num_steps + 1)
  pos_parametric[1] = [start_pos dir]
#   pos_parametric = MakeRandomArray(Float64,2,2*(num_steps + 1))

#   pos_parametric = setindex(pos_parametric, 3, 1,1)
#   pos_parametric = setindex(pos_parametric, 3, 2,1)
#   pos_parametric(Omega())

  for i = 1:num_steps
    p = pos_parametric[i]
    ss = Array(Any, length(obs))
    for j = 1:length(obs)
      d = obs[j]
#       println("d is", p)
      ss[j] = intersect_segments(p, obs[j])
    end
    pos_parametric[i+1] = @If(smallest(ss[1],ss), bounce(p,ss[1],obs[2]),
                              @If(smallest(ss[2],ss),bounce(p,ss[2],obs[2]),
                                  bounce(p,ss[3],obs[3])))
  end
  pos_parametric
end

# 1+1
bbb = simulate_prob(5,obstacles)(Omega())
# bbb

function simulate_prob(num_steps::Integer, obs)
  function (omega)
    obs = map(points_to_parametric, obstacles)
    num_steps = num_steps - 1
    start_pos = Any[4, 5]
    v0,v1 = uniform(0,-1,1)(omega), uniform(1,-1,1)(omega)
    dir  = normalise(Any[v0,v1])
    pos_parametric = Array(Any, num_steps + 1)
    pos_parametric[1] = Any[start_pos dir]

    for i = 1:num_steps
      println("hello")
      p = pos_parametric[i]
      println("hu", length(obs))
      ss = Vector(Any, length(obs))
      println("gma")
      for j = 1:length(obs)
        println("inn", j)
        ss[j] = intersect_segments(p, obs[j])
      end
      pos_parametric[i+1] = @If(smallest(ss[1],ss), bounce(p,ss[1],obs[2]),
                                @If(smallest(ss[2],ss),bounce(p,ss[2],obs[2]),
                                    bounce(p,ss[3],obs[3])))
    end
    pos_parametric
  end
end

function intersect_segments_prob(p0x,p0y,q0x,q0y, u1, u2, v1, v2)
  w1 = p0x - q0x
  w2 = p0y - q0y

  u = p[:,2]
  v = q[:,2]
  (v2 * w1 - v1 * w2) / (v1 * u2 - v2 * u1)
end

# function simulate_prob(num_steps::Integer, obs)
#   obs = map(points_to_parametric, obstacles)
#   num_steps = num_steps - 1
#   start_pos = [4, 5]

#   ray = MakeRandomArray(Float64,2,2*(num_steps + 1))

#   ray = setindex(ray, 4, 1,1)
#   ray = setindex(ray, 5, 2,1)
#   ray = setindex(ray, uniform(0,-1,1), 1,2)
#   ray = setindex(ray, uniform(1,-1,1), 2,2)

#   for i = 1:num_steps
#     p = ray[i]
#     p0x, p0y, u1, u2 = ray[1,1],ray[2,1],ray[1,2],ray[2,2]

#     ss = MakeRandomArray(Any, length(obs), 1)
#     for j = 1:length(obs)
#       o = obs[j]
#       q0x, q0y, v1, v2 = o[1,1],o[2,1],o[1,2],o[2,2]
# #       println("d is", p)
#       s = intersect_segments(p0x,p0y,q0x,q0y, u1, u2, v1, v2)
#       ss = setindex(ss,s,i,1)
#     end
#     pos_parametric[i+1] = @If(smallest(ss[1],ss), bounce(p,ss[1],obs[2]),
#                               @If(smallest(ss[2],ss),bounce(p,ss[2],obs[2]),
#                                   bounce(p,ss[3],obs[3])))
#   end
#   pos_parametric
# end

# ray = simulate_prob(2, obstacles)
# a = simulation_prob[2,:]

# simulation_prob(Omega())

## ====
## Vis
function make_point_pairs(lines)
  b = Array(Any, length(lines)-1)
  for i = 1:length(lines) - 1
    j = i + 1
    b[i] = [lines[i][:,1] lines[j][:,1]]
  end
  b
end

pair(x) = x[1],x[2]

function make_compose_lines(point_pairs)
  [line([pair(o[:,1]), pair(o[:,2])]) for o in point_pairs]
end

function draw_lines(lines...)
  all_lines = apply(vcat,lines)
  x = map(l->(context(units=UnitBox(0, 0, 10, 10)),
              l,
              linewidth(.5mm),
              stroke(rand_color()),
              fill(nothing)),
          all_lines)
  apply(compose,vcat(context(), x))
end

rand_color() = RGB(rand(),rand(),rand())

## ========
## Examples

obstacles = Array[[8.01 3.01; 1.02 9],
                  [0.5 3.08; 2.02 9.04],
                  [0.0 9.99; 3 5.04]]

simulation = simulate(10, obstacles)
a = make_compose_lines(obstacles)
b = make_compose_lines(make_point_pairs(simulation))

draw_lines(a,b)
