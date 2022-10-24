require_relative "Modules"
include IntegralFunction # модуль підінтегральних функцій
include DirectIntegration # модуль проінтегрованих функцій
include RectangleModule # модуль методу прямокутників
include MonteKarloSimple # модуль простого методу Монте-Карло

# x_down = y_down = z_down = 0
# x_up = y_up = z_up = 1
a = u = k = rec_step =  0
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

# безпосереднє інтегрування кожної підінтегральної функції
first_direct_integration = func_one_integration(a, up) - func_one_integration(a, down)
two_direct_integration = func_two_integration(u, up) - func_two_integration(u, down)
three_direct_integration = func_three_integration(k, up) - func_three_integration(k, down)

# розрахунок результату безпосереднього інтегрування
puts("Результат безпосереднього інтегрування: #{dir_integration_res = first_direct_integration * two_direct_integration * three_direct_integration}")

# розрахунок результату методом прямокутників
puts("\nРезультат методу прямокутників: #{rectangle_method_res = rectangle_method(down, up, a, u, k, rec_step)}
Помилка методу прямокутників: #{(dir_integration_res - rectangle_method_res).abs}
Похибка методу прямокутніків (формула Рунге): #{runge(down, up, a, u, k, rec_step)}")

# розрахунок результату простим методом Монте-Карло
puts("\nРезультат простого методу Монте-Карло: #{monte_karlo_simple_method_res = monte_karlo_simple_method(up, down, a, u, k, ((up - down) / rec_step).to_i)}
Помилка простого методу Монте-Карло: #{(dir_integration_res - monte_karlo_simple_method_res).abs}
Похибка простого методу Монте-Карло: #{(calculate_inaccuracy(up, down, a, u, k, ((up - down) / rec_step).to_i) / 3).abs}")


# ((rectangle_method(down, up, a, u, k, rec_step) - rectangle_method(down, up, a, u, k, 2 * rec_step)) / 3).abs