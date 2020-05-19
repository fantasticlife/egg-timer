class Date
  
  # cycles to get first sitting day in either House
  def first_sitting_day
    unless self.is_sitting_day?
      self.next_day.first_sitting_day
    else
      self
    end
  end
  
  # cycles to get first joint sitting day
  def first_joint_sitting_day
    
    # If this is an as yet unannounced day...
    if self.is_unannounced?
      
      # ...give up finding a first joint sitting day
      return nil
    
    # If this isn't an as yet unnanounced day...
    else
      
      # ...if this is not a joint sitting day, go check the next one
      unless self.is_joint_sitting_day?
        self.next_day.first_joint_sitting_day
        
      # ..if this is a joint sitting day, return it
      else
        self
      end
    end
  end
  
  # checks if a date is a sitting day in either House
  def is_sitting_day?
    is_sitting_day_flag = false
    is_sitting_day_flag = true if self.is_commons_sitting_day? or self.is_lords_sitting_day?
    is_sitting_day_flag
  end
  
  # checks if a date is a bicameral sitting day
  def is_joint_sitting_day?
    is_joint_sitting_day_flag = false
    is_joint_sitting_day_flag = true if self.is_commons_sitting_day? and self.is_lords_sitting_day?
    is_joint_sitting_day_flag
  end
  
  # check if either house is sitting on a day
  def is_sitting_day?
    sitting_day_flag = false
    sitting_day = SittingDay.all.where( 'start_date <= ?',  self ).where( 'end_date >= ?',  self ).first
    sitting_day_flag= true if sitting_day
    sitting_day_flag
  end
  
  # check if either house is adjourned on a day
  def is_adjournment_day?
    adjournment_day_flag = false
    adjournment_day = AdjournmentDay.all.where( 'date = ?',  self ).first
    adjournment_day_flag= true if adjournment_day
    adjournment_day_flag
  end
  
  # check if parliament is prorogued on a day
  def is_prorogation_day?
    prorogation_day_flag = false
    prorogation_day = ProrogationDay.all.where( 'date = ?',  self ).first
    prorogation_day_flag= true if prorogation_day
    prorogation_day_flag
  end
  
  # check if parliament is dissolved on a day
  def is_dissolution_day?
    dissolution_day_flag = false
    dissolution_day = DissolutionDay.all.where( 'date = ?',  self ).first
    dissolution_day_flag= true if dissolution_day
    dissolution_day_flag
  end
  
  # check if the commons is sitting on a day
  def is_commons_sitting_day?
    sitting_day_flag = false
    sitting_day = SittingDay.all.where( 'start_date <= ?',  self ).where( 'end_date >= ?',  self ).where( house_id: 1 ).first
    sitting_day_flag= true if sitting_day
    sitting_day_flag
  end
  
  # check if the commons is adjourned on a day
  def is_commons_adjournment_day?
    adjournment_day_flag = false
    adjournment_day = AdjournmentDay.all.where( 'date <= ?',  self ).where( house_id: 1 ).first
    adjournment_day_flag= true if adjournment_day
    adjournment_day_flag
  end
  
  # check if the lords is sitting on a day
  def is_lords_sitting_day?
    sitting_day_flag = false
    sitting_day = SittingDay.all.where( 'start_date <= ?',  self ).where( 'end_date >= ?',  self ).where( house_id: 2 ).first
    sitting_day_flag= true if sitting_day
    sitting_day_flag
  end
  
  def is_unannounced?
    is_unprogrammed = true
    is_unprogrammed = false if self.is_sitting_day? or self.is_adjournment_day? or self.is_prorogation_day? or self.is_dissolution_day?
    is_unprogrammed
  end
  
  # Checks if this is a short adjournment date in the Commons
  # The definition of "short is adjustable" by passing in a maximum number of days to count as "short"
  def is_commons_short_adjournment?( maximum_day_count )
    
    # Check if this is an adjournnment day
    if self.is_commons_adjournment_day?
      
      # Set the adjournment day count to start at 1
      adjournment_day_count = 1
      
      # Cycle through the following days according to the maximum day count passed in.
      date = self
      for i in ( 1..maximum_day_count )
        
        # Go forward one day
        date = date.next_day
        
        # If this is an adjournment day in the Commons
        if date.is_commons_adjournment_day?
          
          # Add one to the adjournment day count
          adjournment_day_count +=1
        
        # If it's not an adjournment day...
        else  
          
          # ...stop cycling forward
          break
        end
      end
      
      # Cycle through the preceding days according to the maximum day count passed in.
      date = self
      for i in ( 1..maximum_day_count )
        
        # Go back one day
        date = date.prev_day
        
        # If this is an adjournment day in the Commons
        if date.is_commons_adjournment_day?
          
          # Add one to the adjournment day count
          adjournment_day_count +=1
        
        # If it's not an adjournment day...
        else  
          
          # ...stop cycling backward.
          break
        end
      end

      # If there's more than the maximum number of adjournment days passed in...
      if adjournment_day_count > maximum_day_count
      
        # ...this is not a short adjournment and does not count on the clock
        is_commons_short_adjournment = false
      
      # If this is 4 or more days adjournment...
      else  
      
        # ....this is a short adjournnment and does count on the clock
        is_commons_short_adjournment = true
      end
      is_commons_short_adjournment
    end
    
    
    
    
  end
end