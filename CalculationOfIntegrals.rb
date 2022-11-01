require 'benchmark'
require_relative "Modules"
include IntegralFunction # модуль підінтегральних функцій
include DirectIntegration # модуль проінтегрованих функцій
include RectangleModule # модуль методу прямокутників
include MonteKarloSimple # модуль простого методу Монте-Карло
include MonteKarloHard # модуль геометричного методу Монте-Карло

a = u = k = rec_step = 0
down = 0
up = 1

while 1

  begin
    puts "Введіть параметри функції (a, u, k).\nПриклад: 1, 1.2, -1, -1,2."
    puts "a:"
    a = Float(STDIN.gets.chomp).to_f
    puts "u:"
    u = Float(STDIN.gets.chomp).to_f
    puts "k:"
    k = Float(STDIN.gets.chomp).to_f

    while 1
      puts "Введіть крок для розрахунку (приклад: 0.0001):"
      rec_step = STDIN.gets.chomp.to_f

      if rec_step <= 0 or rec_step >= 1
        puts "Введено не коректне значення параметру."
      else
        break
      end

    end

    puts "Кількіть обчислень для методів Монте-Карло:\n#{((up - down) / rec_step).to_i}"

    break

  rescue ArgumentError
    puts "Введено не коректне значення параметру."
  end
end

# розрахунок результату безпосереднього інтегрування
puts("Результат безпосереднього інтегрування: #{dir_integration_res = calculate_integration(up, down, a, u, k)}
Час виконання безпосереднього інтегрування: #{Benchmark.measure { calculate_integration(up, down, a, u, k) }.real} c.")

# розрахунок результату методом прямокутників
puts("\nРезультат методу прямокутників: #{rectangle_method_res = rectangle_method(down, up, a, u, k, rec_step)}
Помилка методу прямокутників: #{(dir_integration_res - rectangle_method_res).abs}
Похибка методу прямокутників (формула Рунге): #{runge_inaccuracy(down, up, a, u, k, rec_step)}
Час виконання методу прямокутників: #{Benchmark.measure { rectangle_method(down, up, a, u, k, rec_step) }.real} c.")

# розрахунок результату найпростішим методом Монте-Карло
inaccuracy_simple = inaccuracy(up, down, a, u, k, ((up - down) / rec_step).to_i)
puts("\nРезультат найпростішого методу Монте-Карло: #{monte_karlo_simple_method_res = monte_karlo_simple_method(up, down, a, u, k, ((up - down) / rec_step).to_i)}
Помилка найпростішого методу Монте-Карло: #{(dir_integration_res - monte_karlo_simple_method_res).abs}
Похибка найпростішого методу Монте-Карло: #{inaccuracy_simple.dig(:inaccuracy)}
Час виконання найпростішого методу Монте-Карло: #{Benchmark.measure { monte_karlo_simple_method(up, down, a, u, k, ((up - down) / rec_step).to_i) }.real} c.
Трудомісткість: #{inaccuracy_simple.dig(:dispersion) * (Benchmark.measure { monte_karlo_simple_method(up, down, a, u, k, ((up - down) / rec_step).to_i) }.real / ((up - down) / rec_step).to_i)} с.")

# розрахунок результату геометричним методом Монте-Карло
inaccuracy_hard = inaccuracy_hard_monte_karlo(up, down, a, u, k, ((up - down) / rec_step).to_i, rec_step)
puts("\nРезультат геометричного методу Монте-Карло: #{monte_karlo_hard_method_res = monte_karlo_hard_method(up, down, a, u, k, ((up - down) / rec_step).to_i, rec_step)}
Помилка геометричного методу Монте-Карло: #{(dir_integration_res - monte_karlo_hard_method_res).abs}
Похибка геометричного методу Монте-Карло: #{inaccuracy_hard.dig(:result_inaccuracy)}
Час виконання геометричного методу Монте-Карло: #{Benchmark.measure { monte_karlo_hard_method(up, down, a, u, k, ((up - down) / rec_step).to_i, rec_step) }.real} c.
Трудомісткість: #{(Benchmark.measure { temp_method_eps(up, down, a, u, k, ((up - down) / rec_step).to_i) }.real / ((up - down) / rec_step).to_i) * inaccuracy_hard.dig(:dispersion)} с.")
