case $1 in
	-tap )
		echo "Gonna do the TAP study"

		case $2 in
			prep )
				echo "execute Preprocessing stuff"
				case $3 in
					-loop )
							echo "and were gonna loop all subjects"							
							case $4 in
								all )
									echo "we are doing all preprocessing steps"
									;;
								tcat )
									echo "we are running 3dTcat"
									;;
							esac
							;;
					* )
						echo "Looks like a single subject run"
					;;
				esac
			;;
			regress )
					case $3 in
						-loop )
							echo "and were gonna loop all subjects"							
							case $4 in
								all )
									echo "we are doing all preprocessing steps"
									;;
								deconvolve )
									echo "run the deconvolution"
									;;
							esac
							;;
					esac
					echo "perform Regression analysis"
			;;
		esac
	;;
	-rat )
		echo "The RAT study"
	-i | -help )
	;;
esac