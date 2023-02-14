# # BMC_AdaptdcosFigures
This is the GitHub repository for the following manuscript in preperation:

V1 does not undergo dichoptic cross orientation suppression at the onset of binocular rivalry flash suppression						
Brock M. Carlson, Blake A. Mitchell1, Kacie Dougherty, Jacob A. Westerberg, Michele A. Cox, & Alexander Maier

# ABSTRACT 
The role of primate primary visual cortex (V1) for binocular rivalry is debated. Existing work has predominantly studied V1’s contribution to the perceptual alternations that occur after binocular rivalry stimuli are observed for several seconds. Here, we assess V1’s role for the onset of binocular rivalry that occurs immediately after stimuli are presented. Recent observations suggest that V1 initiates binocular rivalry by paving the way for selection of one eye’s view (Lee et al., 2007), while later stages of visual processing are required for this selection to be promoted to conscious perception. A leading hypothesis that could provide a mechanistic explanation for V1’s role in initiating binocular rivalry is based on dichoptic cross orientation suppression (dCOS) (Cox et al., 2019; Sengpiel, Blakemore, et al., 1995). dCOS describes the indiscriminate reduction of V1 visual responses that occurs when incompatible stimuli are simultaneously presented to the eyes. By reducing response magnitude, dCOS destabilizes cortical stimulus representations. It has been hypothesized that this destabilization of V1 representations paves the way for destabilized perception. Here we utilize binocular rivalry flash suppression (BRFS) to test this hypothesis. BRFS incorporates a period of monocular adaptation before presenting binocular incompatible (rivalrous) stimuli. BRFS results in onset of binocular rivalry as soon as the monocular adaptation period ends. We hypothesized that if initiation of binocular rivalry is dependent on dCOS, then BRFS should elicit dCOS at the onset of the incompatible stimuli. To test this prediction, we compared V1 spiking responses in two awake and behaving macaques as they passively observed BRFS. We found that BRFS resulted in facilitation rather than suppression of binocular responses. This finding suggests that dichoptic suppression in V1 does not serve as a general prerequisite for, nor as initiator of, binocular rivalry. We propose that in the particular case of BRFS the adaptation period, which reduced V1 activity, may adequality destabilize V1’s visual representation in place of dCOS. 

# USING THIS REPOSITORY
This repository is published under the GNU GPL v3.0 license.
This repository is for the creation of figures in the current version of
the manuscript. If you would like the pre-processed data required to run
this code, please email Brock Carlson at brock.m.carlson@vanderbilt.edu

## Setup
The function PostSetup.m establishes your main directories as globals
The script *Controller.m* is the only interface you should need to interact
with. It runs the following processes:

1. makeIDX. IDX_ is a (Nx1) structure variable where N in the number of
individual units. The fields contain metadata about each unit as well as 
event-locked data.

2. plot continuous data with Gramm

3. format data for input to JASP
 

## Dependencies
This script also requires the following toolboxes to run:
- NPMK from Blackrock
- Gramm