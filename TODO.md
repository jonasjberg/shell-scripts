www2png
-------

* If the resulting image is taller then some set height, cut and paste
  horizontally. 
  Pseudo-code:

        i = 0
        if (image.height > heightMax)

            cutFromHereY = ((heightMax * i) + heightMax)

            /* Adjust if not empty? */
            while (area at cutFromHereY != white)
            do
                cutFromHereY++
            done
            
            cut from (0, 0) to (0, heightMax)       // all x, y positions
            paste to (image.width, 0)               // upper left corner only ..

        fi



