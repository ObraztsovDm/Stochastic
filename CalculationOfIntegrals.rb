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
    puts "Введіть параметри функції (a, u, k). Тільки цілі значення:"
    puts "a:"
    a = Integer(STDIN.gets.chomp).to_f
    puts "u:"
    u = Integer(STDIN.gets.chomp).to_f
    puts "k:"
    k = Integer(STDIN.gets.chomp).to_f

    while 1
      puts "Введіть крок для методу розрахунку за методом прямокутників (приклад: 0.0001):"
      rec_step = STDIN.gets.chomp.to_f

      if rec_step <= 0 or rec_step >= 1
        puts "Введено не коректне значення параметру."
      else
        break
      end

    end

=begin
    puts "Введіть кількіть обчислень для методів Монте-Карло:"
    num_calculations = Integer(STDIN.gets.chomp)
=end

    break

  rescue ArgumentError
    puts "Введено не коректне значення параметру."
  end
end

# розрахунок результату безпосереднього інтегрування
puts("Результат безпосереднього інтегрування: #{dir_integration_res = calculate_integration(up, down, a, u, k)}")

# розрахунок результату методом прямокутників
puts("\nРезультат методу прямокутників: #{rectangle_method_res = rectangle_method(down, up, a, u, k, rec_step)}
Помилка методу прямокутників: #{(dir_integration_res - rectangle_method_res).abs}
Похибка методу прямокутніків (формула Рунге): #{runge_inaccuracy(down, up, a, u, k, rec_step)}")

# розрахунок результату простим методом Монте-Карло
puts("\nРезультат простого методу Монте-Карло: #{monte_karlo_simple_method_res = monte_karlo_simple_method(up, down, a, u, k, ((up - down) / rec_step).to_i)}
Помилка простого методу Монте-Карло: #{(dir_integration_res - monte_karlo_simple_method_res).abs}
Похибка простого методу Монте-Карло: #{inaccuracy(up, down, a, u, k, ((up - down) / rec_step).to_i)}")

# розрахунок результату геометричним методом Монте-Карло
puts("\nРезультат геометричного методу Монте-Карло: #{monte_karlo_hard_method_res = monte_karlo_hard_method(up, down, a, u, k, ((up - down) / rec_step).to_i, rec_step)}
Помилка геометричного методу Монте-Карло: #{(dir_integration_res - monte_karlo_hard_method_res).abs}
Похибка геометричного методу Монте-Карло: #{inaccuracy_hard_monte_karlo(up, down, a, u, k, ((up - down) / rec_step).to_i, rec_step)}")

# min_max_func(down, up, a, u, k, rec_step)
# test(up, down, a, u, k, ((up - down) / rec_step).to_i)
#monte_karlo_hard_method_res = monte_karlo_hard_method(up, down, a, u, k, ((up - down) / rec_step), rec_step)