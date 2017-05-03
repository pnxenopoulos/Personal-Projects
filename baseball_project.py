######### Tim Boudreau #########
######### May 1 2017 #########
######### Baseball Project to Learn Python #########

###############################
# Set up the code: import packages and data management
###############################

# import and use libraries we need

import pandas as pd
import scipy as sp
import matplotlib.pyplot as plt
import locale 								# for currency
import statsmodels.formula.api as sm 		# for regression 

from matplotlib.ticker import FuncFormatter

# set location for currency, for salary currency formatting

locale.setlocale( locale.LC_ALL, '' )

# call our data, team statistics and player salaries

teams = pd.read_csv('/Users/Tim/Desktop/Python/lahman-csv_2014-02-14/Teams.csv')
salaries = pd.read_csv('/Users/Tim/Desktop/Python/lahman-csv_2014-02-14/Salaries.csv')

# select team data since 1985, with specific attributes for baseball stats

teams = teams[teams['yearID'] >= 1985]
teams = teams[['yearID', 'teamID', 'Rank', 'R', 'RA', 'G', 'W', 'H', 'BB', 'HBP', 'AB', 'SF', 'HR', '2B', '3B']]

# change data indexing

teams = teams.set_index(['yearID', 'teamID'])
salaries = salaries.groupby(['yearID', 'teamID'])['salary'].sum()

# add salaries to teams dataframe

teams = teams.join(salaries)

# example to check if code is right: Amount of wins and salary for Oakland & Giants in 2001

print('\nOakland A\'s 2001 wins: %d  \nTeam salary: %s' % (teams['W'][2001, 'OAK'], locale.currency(teams['salary'][2001, 'OAK'], grouping=True)))
print('\nSF Giants 2001 wins: %d  \nTeam salary: %s \n' % (teams['W'][2001, 'SFN'], locale.currency(teams['salary'][2001, 'SFN'], grouping = True)))

# plot salary versus wins, to visualize the relationship between $$ and success

#plt.plot(teams['salary'][2001], teams['W'][2001])
#plt.show()


###############################
# create functions to plot (note: I did not create these, but can interpret them)
###############################

# function to use money format for x-axis

def millions(x, pos):
    'The two args are the value and tick position'
    return '$%1.1fM' % (x*1e-6)

formatter = FuncFormatter(millions)

# plotting function, designating specific points for OAK, BOS and NYY

def plot_spending_wins(teams, year):    # define function and input variables
    
    teams_year = teams.xs(year)			# returns cross section of data frame teams
    fig, ax = plt.subplots()			# add figure and axis objects
    

    # for loop to find which data point is OAK, BOS or NYY
	# if the point is OAK, BOS or NYY, scatter plot salary and wins, with annotation for team

    for i in teams_year.index:
        if i == 'OAK':
            ax.scatter(teams_year['salary'][i], teams_year['W'][i], color="#4DDB94", s=200)	
            ax.annotate(i, (teams_year['salary'][i], teams_year['W'][i]),
                        bbox=dict(boxstyle="round", color="#4DDB94"),
                        xytext=(-30, 30), textcoords='offset points',
                        arrowprops=dict(arrowstyle="->", connectionstyle="angle,angleA=0,angleB=90,rad=10"))
        elif i == 'NYA':
            ax.scatter(teams_year['salary'][i], teams_year['W'][i], color="#0099FF", s=200)
            ax.annotate(i, (teams_year['salary'][i], teams_year['W'][i]),
                        bbox=dict(boxstyle="round", color="#0099FF"),
                        xytext=(30, -30), textcoords='offset points',
                        arrowprops=dict(arrowstyle="->", connectionstyle="angle,angleA=0,angleB=90,rad=10"))
        elif i == 'BOS':
            ax.scatter(teams_year['salary'][i], teams_year['W'][i], color="#FF6666", s=200)
            ax.annotate(i, (teams_year['salary'][i], teams_year['W'][i]),
                        bbox=dict(boxstyle="round", color="#FF6666"),
                        xytext=(-30, -30), textcoords='offset points',		# changed location of BOS displayed
                        arrowprops=dict(arrowstyle="->", connectionstyle="angle,angleA=0,angleB=90,rad=10"))     
        else:
            ax.scatter(teams_year['salary'][i], teams_year['W'][i], color="grey", s=200)
    

    # axis details, such as formatter, labels and size, title, etc.

    ax.xaxis.set_major_formatter(formatter) 
    ax.tick_params(axis='x', labelsize=15)
    ax.tick_params(axis='y', labelsize=15)
    ax.set_xlabel('Salaries', fontsize=20)
    ax.set_ylabel('Number of Wins' , fontsize=20)
    ax.set_title('Salaries - Wins: '+ str(year), fontsize=25, fontweight='bold')
    plt.draw()


###############################
# end function, back to my code
###############################


# now, using the function, plot spending versus wins, with axis labels
# highlighting Boston, New York and Oakland

plot_spending_wins(teams, 2001)


###############################
# Baseball Modeling
###############################


# Since we are modeling the 2001 Oakland A's Billy Beane's analyses,
# we must set up the stats needed

# Batting Average ( H/AB )
# On Base Percentage ( (H+BB+HBP) / (AB+BB+HBP+SF) )
# Slugging Percentage ( (H+2B+(2*3B)+(3*HR)) / AB)

teams['BA'] = teams['H'] / teams['AB']
teams['OBP'] =  (teams['H'] + teams['BB'] + teams['HBP']) / (teams['AB'] + teams['BB'] + teams['HBP'] + teams['SF'])
teams['SLG'] = (teams['H'] + teams['2B'] + (2*teams['3B']) + (3*teams['HR'])) / teams['AB']

# If a team scores more runs than it allows, it wins. We will model to predict runs scored.
# Will try three models: 	1) OBP, SLG, BA 	2) OBP, SLG 	3) BA

# First model: OBP, SLG, BA

runs_reg_model1 = sm.ols("R~OBP+SLG+BA", teams)
runs_reg1 = runs_reg_model1.fit()

# Second model: OBP, SLG

runs_reg_model2 = sm.ols("R~OBP+SLG", teams)
runs_reg2 = runs_reg_model2.fit()

# Third model: BA

runs_reg_model3 = sm.ols("R~BA", teams)
runs_reg3 = runs_reg_model3.fit()

# print the model summaries (commented out for convenience)

#print runs_reg1.summary()	# flawed - BA can't be negative, it is here due to multicollinearity with SLG
#print runs_reg2.summary()	# highest R-Squared
#print runs_reg3.summary()	# low R-Squared

print("\nThe optimal model to predict runs scored is model 2: " \
	"runs is predicted by OBP and SLG with an R-Squared of %.4f.\n" % runs_reg2.rsquared)



plt.show()