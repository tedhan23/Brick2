require 'ruby2d' #similar to import in other languages

#similar to frame setup in java. basic info about the window
set title: "Brick 2!", background: [38, 219, 255, 1], viewport_width: 1920, viewport_height: 1080, resizable: true, width: 1920, height: 1080

@scale = 0.5 #scale of how many meters to a pixel. this was really hard to do the way I wanted, and I'm not even 100% sure this is labeled properly. I can fix that later
#however, fixing that would be a HUGE hassle as I've already made it consistent to be like this (complete nonsense, the smaller scale is a larger scale) with multiple
#different variables and whatnot. doable, but I don't want to right now.

@tick = 0 #keeps track of time elapsed while running in the update loop

@m = 2 #mass of the brick
@ay = -0.3267 * @scale #acceleration of the brick
@muk = 0.5 #coefficient of kinetic friction
@vx = 0 #velocities of the brick
@vy = 0

info_background = Rectangle.new( #a whit box that the info text goes into
  x: 1520, y: 0,
  z: 22,
  width: 400, height: 360,
  color: 'white'
)

@brick_info = Text.new( #displays brick velocity. poorly named because can't do new line, but doesn't seem to be worth the hassle to change
  "Vertical velocity: #{@vy} m/s",
  x: 1540, y: 20,
  z: 23,
  size: 20,
  color: 'black'
)

@mouse_info = Text.new( #displays mouse position
  "Mouse position: #{(Window.mouse_x * @scale).round(10)} m, #{((980-Window.mouse_y) * @scale).round(10)} m",
  x: 1540, y: 50,
  z: 23,
  size: 20,
  color: 'black'
)

b = Image.new( #the brick itself
  'brick.png',
  x: 500, y: 0,
  z: 20
)

@masstext = Text.new( #displays the brick's weight on the brick. I plan on making the mass tweakable
  "#{@m} kg",
  x: b.x+10, y: b.y+10,
  z: 23,
  size: 20,
  color: 'black'
)

ground = Rectangle.new( #the ground
  x: 0, y: 980,
  z: 21,
  width: 2080, height: 100,
  color: [40, 145, 0] 
)

Text.new( #info to close the window. used to be fullscreen by default, so I had to code in a way to exit without using ctrl/alt/delete
  'Press x to close the window.',
  x: 10, y: 10,
  style: 'italic',
  size: 20,
  color: 'red',
)

#text that outputs distance scaling. likely only needed in the update loop.
@scaler1 = Text.new(
  "Scale: 1 px = #{@scale.round(4)} meter(s) (use o and p keys to decrease or increase)",
  x: 700, y: 10,
  size: 20,
  color: 'black',
)

on :key_down do |event| #keyboard inputs
  if event.key == 'x' #closes the window, as the window is completely borderless and is very hard to close otherwise
    close
  elsif event.key == 'r' #reset button - brings the brick back to its starting point
    @vy = 0
    @vx = 0
    b.y = 0
    b.x = 500
  elsif event.key == 'p' #increases the scale
    @scale = @scale + 0.1
  elsif event.key == 'o' #decreases the scale
    @scale = @scale - 0.1
  #elsif event.key == 'w'
    #@vy = @vy+10
  #elsif event.key == 's'
    #@vy = @vy-10
  #elsif event.key == 'd'
    #@vx = @vx+10
  #elsif event.key == 'a'
    #@vx = @vx-10
  end
end

on :mouse_down do |event|
  case event.button
  when :left

  when :middle

  when :right
      if b.y > 920
        b.y = Window.mouse_y #supposedly teleports brick to mouse if brick is on the ground because of an issue with sticking (partially fixed?)
        b.x = Window.mouse_x #however, this code does nothing for no apparent reason
      end

      @vx = 0.25 * @scale * (Window.mouse_x - b.x)
      @vy = 0.25 * @scale * (b.y - Window.mouse_y)
  end
end

update do #update loop. happens 60 times per second
  @scaler1.remove #clears last frame's scale info so it doesn't stack over itself
  @brick_info.remove
  @mouse_info.remove

  @ay = -0.3267 / @scale #updates acceleration value based on scale

  #if b.y < 920 #only does this when brick isn't at the bottom of the screen
    if @tick % 2 == 0 #on even ticks, ie every other frame, update brick displacement with velocity
      b.y = b.y-@vy
      b.x = b.x+@vx
      if b.y > 920 #keeps the brick above ground
        b.y = 920

        @vy = 0
        #@ay = 0
      else
        @vy = @vy + @ay #every tick, update velocity
      end
      if b.y >= 920
        if @vx > 0
          @vx = @vx - (@muk * @m * -1 * @ay) #if vx is positive, friction force pushes left. this is buggy because the control for @ay is kind of busted
        elsif @vx < 0
          @vx = @vx + (@muk * @m * -1 * @ay) #if vx is negative, friction force pushes right
        end
      end
    end
    #the above chunk of code is very broken. currently, the brick jiggles back and forth when on the ground. I can get a working vertical velocity reading,
    #the ability to throw the brick off the ground, OR have working friction. apparently not all three. this is the major issue to be resolved right now

    @masstext.x = b.x+10 #makes the weight label follow the brick
    @masstext.y = b.y+10
    @tick = @tick + 1 #increment tick
  #end
  @scaler1 = Text.new( #add updated scale info
    "Scale: 1 px = #{@scale.round(4)} meter(s) (use o and p keys to decrease or increase)",
    x: 700, y: 10,
    size: 20,
    color: 'black',
  )
  if b.contains? Window.mouse_x, Window.mouse_y #makes the brick green if you hover over it
    b.color = 'green'
  else
    b.color = 'white'
  end
  @brick_info = Text.new( #refreshes brick info
    "Vy: #{@vy.round(5)} m/s, Vx: #{@vx.round(5)} m/s",
    x: 1540, y: 20,
    z: 23,
    size: 20,
    color: 'black'
  )
  @mouse_info = Text.new( #refreshes mouse info
    "Mouse position: #{(Window.mouse_x * @scale).round(10)} m, #{((980-Window.mouse_y) * @scale).round(10)} m",
    x: 1540, y: 50,
    z: 23,
    size: 20,
    color: 'black'
  )
end

#renders the program
show
