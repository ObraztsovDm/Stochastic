require 'benchmark'
=begin
puts "Введіть параметри моделі"

count_ns = 0
thickness = 0.0
pa = 0.0
kr = 0.0
mu = 0.0
=end
hade = 45.0
thickness = 2.0
count_ns = 10000

mu = 1.0
pa = 0.001
kr = 1.0

=begin
while 1
  begin
    puts "Статистика (Ns):"
    count_ns = Integer(STDIN.gets.chomp)

    if count_ns > 0
      break
    else
      puts "Введено від'ємне значення. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Введено не ціле значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Товщина шару:"
    thickness = Float(STDIN.gets.chomp)

    if thickness > 0
      break
    else
      puts "Введено від'ємне значення. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Кут падіння:"
    hade = Float(STDIN.gets.chomp)

    if hade > 0
      break
    else
      puts "Введено від'ємне значення. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Введено не ціле значення. Повторіть вибір"
  end
end

puts "\nВведіть параметри взаємодії\n\n"

while 1
  begin
    puts "Ймовірність поглинання:"
    pa = Float(STDIN.gets.chomp)

    if pa >= 0 and pa <= 1
      break
    else
      puts "Помилка. Значення цього параметру має бути в діапазоні від 0 до 1"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Параметр розкиду:"
    kr = Float(STDIN.gets.chomp)

    if kr >= 0
      break
    else
      puts "Введено від'ємне значення. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end

while 1
  begin
    puts "Довжина вільного пробігу:"
    mu = Float(STDIN.gets.chomp)

    if mu > 0
      mu = 1 / mu
      break
    else
      puts "Введено від'ємне значення. Повторіть вибір"
    end
  rescue ArgumentError
    puts "Не коректне значення. Повторіть вибір"
  end
end
=end

def calculation(count_ns, thickness, pa, kr, mu, hade)
  f_var = 0.0
  b_var = 0.0
  ab_var = 0.0

  (1..count_ns).each do
    x = 0.0
    cs = Math.cos(Math::PI * hade / 180)
    while 1
      l = -Math.log(rand) / mu
      x1 = x + l * cs

      if x1 < 0
        b_var += 1
        break
      end

      if x1 > thickness
        f_var += 1
        break
      end

      if rand(0.0..1.0) < pa
        ab_var += 1
        break
      end

      com = rand(0.0..1.0) ** (1 / (kr + 1))
      fi = 2 * Math::PI * rand(0.0..1.0)
      cos_1 = cs * com - Math.sqrt((1 - cs * cs) * (1 - com * com)) * Math.sin(fi) # за формулою cos^2 + sin^2 = 1

      x = x1
      cs = cos_1
    end
  end

  q_var1 = (f_var.to_f / count_ns.to_f).round(4)
  q_var2 = (b_var.to_f / count_ns.to_f).round(4)
  q_var3 = (ab_var.to_f / count_ns.to_f).round(4)

  f_ns = Math.sqrt(q_var1 * (1 - q_var1).abs / count_ns.to_f).round(5)
  b_ns = Math.sqrt(q_var2 * (1 - q_var2).abs / count_ns.to_f).round(5)
  ab_ns = Math.sqrt(q_var3 * (1 - q_var3).abs / count_ns.to_f).round(5)

  {
    :Q_F => q_var1,
    :Q_B => q_var2,
    :Q_Ab => q_var3,
    :F_Ns => f_ns,
    :B_Ns => b_ns,
    :Ab_Ns => ab_ns
  }
end

puts "Результати моделювання"
results = calculation(count_ns, thickness, pa, kr, mu, hade)
q_calc = (results.dig(:Q_F) + results.dig(:Q_B) + results.dig(:Q_Ab) / 3) * Benchmark.measure {calculation(count_ns, thickness, pa, kr, mu, hade)}.real / count_ns
puts("Передавальне відношення: #{results.dig(:Q_F)} :::: Похибка: #{results.dig(:F_Ns)}")
puts("Коефіцієнт відбиття:     #{results.dig(:Q_B)} :::: Похибка: #{results.dig(:B_Ns)}")
puts("Коефіцієнт поглинання:   #{results.dig(:Q_Ab)} :::: Похибка: #{results.dig(:Ab_Ns)}")
puts("Трудомісткість:          #{q_calc}")
=begin
puts("Test(Q_f): #{results.dig(:Q_F)}")
puts("Test(Q_b): #{results.dig(:Q_B)}")
puts("Test(Q_ab): #{results.dig(:Q_Ab)}")

puts("Test(F_Ns): #{results.dig(:F_Ns)}")
puts("Test(B_Ns): #{results.dig(:B_Ns)}")
puts("Test(Ab_Ns): #{results.dig(:Ab_Ns)}")
=end
