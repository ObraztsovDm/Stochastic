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

end

=begin
module RectangleModule
  include IntegralFunction

  def rectangle_method(down, up, a, u, k, rec_step)
    sum_func_1 = sum_func_2 = sum_func_3 = 0

    (down..up).step(rec_step) { |temp|
      sum_func_1 += func_one(a, temp)
      sum_func_2 += func_two(u, temp)
      sum_func_3 += func_three(k, temp)
    }

    (up - down) * ((sum_func_1 * sum_func_2 * sum_func_3 / ((up - down) / rec_step ** 3)))
  end

  def calculate(down, up, rec_step, sum_func)
    (up - down) * (sum_func / ((up - down) / rec_step))
  end

  def runge(down, up, a, u, k, rec_step)
    double_step = rec_step * 2

    sum_func_1 = sum_func_2 = sum_func_3 = 0
    sum_func2_1 = sum_func2_2 = sum_func2_3 = 0

    (down..up).step(rec_step) { |temp|
      sum_func_1 += func_one(a, temp)
      sum_func_2 += func_two(u, temp)
      sum_func_3 += func_three(k, temp)
    }

    (down..up).step(double_step) { |temp|
      sum_func2_1 += func_one(a, temp)
      sum_func2_2 += func_two(u, temp)
      sum_func2_3 += func_three(k, temp)
    }

    mistake_1 = calculate(down, up, rec_step, sum_func_1) - calculate(down, up, double_step, sum_func2_1)
    mistake_2 = calculate(down, up, rec_step, sum_func_2) - calculate(down, up, double_step, sum_func2_2)
    mistake_3 = calculate(down, up, rec_step, sum_func_3) - calculate(down, up, double_step, sum_func2_3)

    ((mistake_1 + mistake_2 + mistake_3) / 3).abs
  end
end
=end

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

  def mult_func_sum_by_gaps(down, up, rec_step, sum_func)
    (up - down) * (1 / ((up - down) / rec_step)) * sum_func
  end

  def rectangle_method(down, up, a, u, k, rec_step)
    rectangle_array = rectangle_integration(down, up, a, u, k, rec_step)
    rectangle_array.map { |sum_func| mult_func_sum_by_gaps(down, up, rec_step, sum_func) }.inject(:*)
  end

  def runge(down, up, a, u, k, rec_step)
    double_step = rec_step * 2

    rectangle_array_h = rectangle_integration(down, up, a, u, k, rec_step)
                          .map { |sum_func| mult_func_sum_by_gaps(down, up, rec_step, sum_func) }
    rectangle_array_2h = rectangle_integration(down, up, a, u, k, double_step)
                           .map { |sum_func| mult_func_sum_by_gaps(down, up, double_step, sum_func) }

    (((0..2).map { |idx| rectangle_array_h[idx] - rectangle_array_2h[idx] }.sum) / 3).abs
  end
end

module MonteKarloSimple
  include IntegralFunction

  def calculate(down, up, num_calculations, sum_func)
    (up - down) * sum_func / num_calculations
  end

  def monte_karlo_simple_integration(up, down, a, u, k, num_calculations)
    sum_func_1 = sum_func_2 = sum_func_3 = 0

    for i in 0..num_calculations
      sum_func_1 += func_one(a, rand(down.to_f..up.to_f))
      sum_func_2 += func_two(u, rand(down.to_f..up.to_f))
      sum_func_3 += func_three(k, rand(down.to_f..up.to_f))
    end

    [sum_func_1, sum_func_2, sum_func_3]
  end

  def monte_karlo_simple_method(up, down, a, u, k, num_calculations)
    monte_karlo_simple_integration = monte_karlo_simple_integration(up, down, a, u, k, num_calculations)
    monte_karlo_simple_integration.map { |var| calculate(down, up, num_calculations, var) }.inject(:*)
  end

  def formula_inaccuracy(down, up, num_calculations, sum_func)
    (up - down) * sum_func / num_calculations
  end

  def inaccuracy(up, down, a, u, k, num_calculations)
    sum_func_1 = sum_func_2 = sum_func_3 = 0

    for i in 0..num_calculations
      x = down + (up - down) * rand
      sum_func_1 += func_one(a, x)
      sum_func_2 += func_two(u, x)
      sum_func_3 += func_three(k, x)
    end

    [sum_func_1, sum_func_2, sum_func_3]
  end

  def calculate_inaccuracy(up, down, a, u, k, num_calculations)
    inaccuracy = inaccuracy(up, down, a, u, k, num_calculations)
    inaccuracy.map { |var| formula_inaccuracy(down, up, num_calculations, var) }.sum
  end
end
