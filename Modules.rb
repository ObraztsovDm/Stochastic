module IntegralFunction

  def func_one(a, x)
    a * (1 - x) * x
  end

  def func_two(u, y)
    Math.exp(-u * y)
  end

  def func_three(k, z)
    Math.sin(Math::PI * k * z)
  end

end

module DirectIntegration

  def func_one_integration(a, x)
    ((a * (x ** 2)) / 2) - ((a * (x ** 3)) / 3)
  end

  def func_two_integration(u, y)
    -(1 / (u * Math.exp(u * y)))
  end

  def func_three_integration(k, z)
    -((Math.cos(Math::PI * k * z)) / (Math::PI * k))
  end

  # безпосереднє інтегрування кожної підінтегральної функції
  def calculate_integration(up, down, a, u, k)
    result = []

    result << func_one_integration(a, up) - func_one_integration(a, down)
    result << func_two_integration(u, up) - func_two_integration(u, down)
    result << func_three_integration(k, up) - func_three_integration(k, down)

    result.inject(:*)
  end
end

module RectangleModule
  include IntegralFunction

  def rectangle_integration(down, up, a, u, k, rec_step)
    sum_func_1 = sum_func_2 = sum_func_3 = 0
    (down..up).step(rec_step) { |temp|
      sum_func_1 += func_one(a, temp)
      sum_func_2 += func_two(u, temp)
      sum_func_3 += func_three(k, temp)
    }

    [sum_func_1, sum_func_2, sum_func_3]
  end

  def calculate_rectangle(down, up, rec_step, sum_func)
    (up - down) * (sum_func / ((up - down) / rec_step))
  end

  def rectangle_method(down, up, a, u, k, rec_step)
    rectangle_array = rectangle_integration(down, up, a, u, k, rec_step)
    rectangle_array.map { |sum_func| calculate_rectangle(down, up, rec_step, sum_func) }.inject(:*)
  end

  def runge_inaccuracy(down, up, a, u, k, rec_step)
    double_step = rec_step * 2

    rectangle_array_h = rectangle_integration(down, up, a, u, k, rec_step)
                          .map { |sum_func| calculate_rectangle(down, up, rec_step, sum_func) }
    rectangle_array_2h = rectangle_integration(down, up, a, u, k, double_step)
                           .map { |sum_func| calculate_rectangle(down, up, double_step, sum_func) }

    (((0..2).map { |idx| rectangle_array_h[idx] - rectangle_array_2h[idx] }.sum) / 3).abs
  end
end

module MonteKarloSimple
  include IntegralFunction

  def calculate(up, down, num_calculations, sum_func)
    (up - down) * sum_func / num_calculations
  end

  def monte_karlo_simple_integration(up, down, a, u, k, num_calculations)
    sum_func_1 = sum_func_2 = sum_func_3 = 0
    rand_mas = []

    (0..num_calculations).each {
      g1 = rand
      rand_mas << g1
      x = down + (up - down) * g1
      sum_func_1 += func_one(a, x)
      sum_func_2 += func_two(u, x)
      sum_func_3 += func_three(k, x)
    }

    {
      :func => [sum_func_1, sum_func_2, sum_func_3],
      :rand => rand_mas
    }
  end

  def monte_karlo_simple_method(up, down, a, u, k, num_calculations)
    inaccuracy = monte_karlo_simple_integration(up, down, a, u, k, num_calculations).dig(:func)
    inaccuracy.map { |var| calculate(up, down, num_calculations, var) }.inject(:*)
  end

  def inaccuracy(up, down, a, u, k, num_calculations)
    sum_func_1 = sum_func_2 = sum_func_3 = 0

    temp = monte_karlo_simple_integration(up, down, a, u, k, num_calculations)
    rand_mas = temp.dig(:rand)
    sum_temp = temp.dig(:func).sum

    inaccuracy_sum_1 = (sum_temp / 3).abs / num_calculations

    (0..num_calculations).each {
      g1 = rand_mas.pop
      x = down + (up - down) * g1
      sum_func_1 += func_one(a, x) ** 2
      sum_func_2 += func_two(u, x) ** 2
      sum_func_3 += func_three(k, x) ** 2
    }

    inaccuracy_sum_2 = ([sum_func_1, sum_func_2, sum_func_3].sum / 3).abs / num_calculations

    dispersion = inaccuracy_sum_2 - inaccuracy_sum_1 ** 2

    (up - down) * Math.sqrt(dispersion / num_calculations)
  end
end

module MonteKarloHard
  include IntegralFunction

  def min_max_func(up, down, a, u, k, rec_step)
    f_idx = 1
    f_min_max = Hash.new

    (1..3).each do
      f_min = Float::MAX
      f_max = Float::MIN

      (down..up).step(rec_step) do |var|
        if f_idx == 1
          temp = func_one(a, var)
        elsif f_idx == 2
          temp = func_two(u, var)
        else
          temp = func_three(k, var)
        end

        if temp > f_max
          f_max = temp
        end
        if temp < f_min
          f_min = temp
        end
      end

      f_min_max[f_idx] = [f_min, f_max]
      f_idx += 1
    end

    f_min_max
  end

  def monte_karlo_hard_method(up, down, a, u, k, num_calculations, rec_step)

    f_idx = 1
    result = []

    temp = min_max_func(up, down, a, u, k, rec_step)

    (1..3).each do |var|
      min_max_func = temp.dig(var)
      min = min_max_func[0]
      max = min_max_func[1]
      n_one = 0

      (0..num_calculations).each {
        rand_var = rand(down.to_f..up.to_f)
        x = down + (up - down) * rand_var

        y_1 = min + (max - min) * rand_var

        if f_idx == 1
          if func_one(a, x) > y_1
            n_one += 1
          end
        elsif f_idx == 2
          if func_two(u, x) > y_1
            n_one += 1
          end
        else
          if func_three(k, x) > y_1
            n_one += 1
          end
        end
      }

      result << (up - down) * ((max - min) * n_one / num_calculations.to_f + min)
      f_idx += 1
    end

    result.inject(:*)
  end

  def eps_method(up, down, a, u, k)
    f_idx = 1
    mas_eps = []

    (1..3).each do
      x = rand(down.to_f..up.to_f)
      y = rand(down.to_f..up.to_f)

      if f_idx == 1
        if func_one(a, x) > y
          result = 0
        else
          result = 1
        end
      end

      if f_idx == 2
        if func_two(u, x) > y
          result = 0
        else
          result = 1
        end
      end

      if f_idx == 3
        if func_three(k, x) > y
          result = 0
        else
          result = 1
        end
      end

      mas_eps << result
      f_idx += 1
    end

    mas_eps
  end

  def temp_method_eps(up, down, a, u, k, num_calculations)
    sum_func_1 = sum_func_2 = sum_func_3 = 0

    (0..num_calculations).each {
      temp_eps = eps_method(up, down, a, u, k)
      sum_func_1 += temp_eps[0]
      sum_func_2 += temp_eps[1]
      sum_func_3 += temp_eps[2]
    }

    [sum_func_1, sum_func_2, sum_func_3]
  end

  def inaccuracy_hard_monte_karlo(up, down, a, u, k, num_calculations, rec_step)
    f_idx = 1
    result_inaccuracy = []

    temp_min_max = min_max_func(up, down, a, u, k, rec_step)
    temp_dispersion = temp_method_eps(up, down, a, u, k, num_calculations)

    (1..3).each do |var|
      min_max_func = temp_min_max.dig(var)
      min = min_max_func[0]
      max = min_max_func[1]

      if f_idx == 1
        inc_func = (up - down) * (max - min) * Math.sqrt((temp_dispersion[0].to_f / num_calculations * (1 - temp_dispersion[0].to_f / num_calculations)) / num_calculations)
      elsif f_idx == 2
        inc_func = (up - down) * (max - min) * Math.sqrt((temp_dispersion[1].to_f / num_calculations * (1 - temp_dispersion[1].to_f / num_calculations)) / num_calculations)
      else
        inc_func = (up - down) * (max - min) * Math.sqrt((temp_dispersion[2].to_f / num_calculations * (1 - temp_dispersion[2].to_f / num_calculations)) / num_calculations)
      end

      result_inaccuracy << inc_func
      f_idx += 1
    end

    result_inaccuracy.sum / 3.0
  end
end
