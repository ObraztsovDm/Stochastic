class RandomWandering

  probability_mas = []
  choose_n = 0
  choose_m = 0
  count_ns = 0
  out_north = 0
  out_east = 0
  out_west = 0
  out_south = 0
  x = 0
  y = 0
  absorption = 0

  attr_accessor :x_loc, :y_loc, :is_absorption

  def initialize(var_x, var_y)
    @x_loc = var_x
    @y_loc = var_y
    @is_absorption = false
  end

  while 1
    begin
      puts "Кількість частинок (Ns):"
      count_ns = Integer(STDIN.gets.chomp)

      break
    rescue ArgumentError
      puts "Введено не ціле значення. Повторіть вибір"
    end
  end

  while 1
    begin
      puts "Введіть число ліній з заходу на схід (N):"
      choose_n = Integer(STDIN.gets.chomp)

      break
    rescue ArgumentError
      puts "Введено не ціле значення. Повторіть вибір"
    end
  end

  while 1
    begin
      puts "Число ліній з півночі на південь (M):"
      choose_m = Integer(STDIN.gets.chomp)

      break
    rescue ArgumentError
      puts "Введено не ціле значення. Повторіть вибір"
    end
  end

  while 1
    begin
      puts "Точка старту (n0):"
      x = Integer(STDIN.gets.chomp)

      if x > choose_n
        puts "Помилка. Значення n0 повинно бути більше ніж N"
      else
        break
      end
    rescue ArgumentError
      puts "Введено не ціле значення. Повторіть вибір"
    end
  end

  while 1
    begin
      puts "Точка старту (m0)"
      y = Integer(STDIN.gets.chomp)

      if y > choose_m
        puts "Помилка. Значення m0 повинно бути більше ніж M"
      else
        break
      end
    rescue ArgumentError
      puts "Введено не ціле значення. Повторіть вибір"
    end
  end

  for i in 1..5
    while 1

      if i <= 4
        puts("Ймовірність P#{i}")
      else
        puts("Ймовірність Pa (поглинання)")
      end

      choose = STDIN.gets.chomp.to_f

      if choose >= 1 or choose < 0
        puts "Помилка. Ймовірність менше 0 або більше 1. Повторіть вибір."
      else
        probability_mas << choose
        puts("Залишок значень до одиниці: #{(1 - probability_mas.inject(:+)).round(4)}")
        break
      end
    end
  end

  if probability_mas.sum != 1
    puts "Сумарна ймовірність має дорівнювати 1 і не перевищувати її. Почніть з початку."
    abort
  end

  def check_movement (probability_mas)
    temp = rand

    if temp < probability_mas[0]
      @y_loc += 1
    elsif temp < probability_mas[0] + probability_mas[1]
      @y_loc -= 1
    elsif temp < probability_mas[0] + probability_mas[1] + probability_mas[2]
      @x_loc += 1
    elsif temp < probability_mas[0] + probability_mas[1] + probability_mas[2] + probability_mas[3]
      @x_loc -= 1
    else
      @is_absorption = true
    end
  end

  for i in 1..count_ns
    obj = RandomWandering.new(x, y)

    while obj.x_loc < choose_n and obj.x_loc > 0 and obj.y_loc < choose_m and obj.y_loc > 0 and !obj.is_absorption
      obj.check_movement(probability_mas)
    end

    if obj.is_absorption
      absorption += 1
      #puts "Поглинання"
    else
      if obj.x_loc == choose_n
        #puts "Схід"
        out_east += 1
      elsif obj.x_loc == 0
        out_west += 1
        #puts "Захід"
      elsif obj.y_loc == choose_m
        out_north += 1
        #puts "Північ"
      elsif obj.y_loc == 0
        out_south += 1
        #puts "Південь"
      end
    end
  end

  q_var1 = out_north.to_f / count_ns.to_f
  q_var2 = out_south.to_f / count_ns.to_f
  q_var3 = out_east.to_f / count_ns.to_f
  q_var4 = out_west.to_f / count_ns.to_f
  q_var_a = absorption.to_f / count_ns.to_f

  uns_1 = Math.sqrt(q_var1 * (1 - q_var1) / count_ns.to_f)
  uns_2 = Math.sqrt(q_var2 * (1 - q_var2) / count_ns.to_f)
  uns_3 = Math.sqrt(q_var3 * (1 - q_var3) / count_ns.to_f)
  uns_4 = Math.sqrt(q_var4 * (1 - q_var4) / count_ns.to_f)
  uns_a = Math.sqrt(q_var_a * (1 - q_var_a) / count_ns.to_f)

  puts "Результати"
  puts("Q1 = #{q_var1.round(5)} :::: Uns1 = #{uns_1.round(5)}")
  puts("Q2 = #{q_var2.round(5)} :::: Uns2 = #{uns_2.round(5)}")
  puts("Q3 = #{q_var3.round(5)} :::: Uns3 = #{uns_3.round(5)}")
  puts("Q4 = #{q_var4.round(5)} :::: Uns4 = #{uns_4.round(5)}")
  puts("Qa = #{q_var_a.round(5)} :::: Uns_a = #{uns_a.round(5)}")
end
