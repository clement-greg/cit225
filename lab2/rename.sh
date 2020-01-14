for i in $(ls *[^2].sql); do
  mv $i ${i/./_lab.}
done
