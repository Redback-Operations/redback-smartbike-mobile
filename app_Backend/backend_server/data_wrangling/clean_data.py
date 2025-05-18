from django.db import models, transaction
from django.db.models import Q 
from ..models import WorkoutEntry
import logging


logger = logging.getLogger(__name__)



def clean_missing_values(entries):
    try:
        logger.debug('Starting clean_missing_values function')

        # Identify fields that should not have null values
        fields_to_check = [
            'speed', 'rpm', 'distance', 'heart_rate', 'temperature', 'incline', 'timestamp'
        ]
        logger.debug(f'Fields to check for null values: {fields_to_check}')
        
        # Build the filter condition to find entries with any null values in specified fields
        conditions = Q()
        for field in fields_to_check:
            conditions |= Q(**{f"{field}__isnull": True})
        
        # Apply the filter condition to the provided entries queryset
        initial_count = entries.count()
        logger.debug(f'Initial count of entries: {initial_count}')
        
        entries_to_delete = entries.filter(conditions)
        logger.debug(f'Entries to delete count: {entries_to_delete.count()}')
        
        # Delete entries with null values in specified fields
        with transaction.atomic():
            deleted_count, _ = entries_to_delete.delete()
        
        final_count = initial_count - deleted_count
        logger.debug(f'Final count of entries: {final_count}')

        logger.info(f'Removed {deleted_count} entries with missing values')
        logger.debug('Finished clean_missing_values function successfully')
        
        return final_count
    except Exception as e:
        logger.error(f'Error in clean_missing_values function: {e}')
        raise


def remove_duplicates(data):
    try:
        logger.debug('Starting remove_duplicates function')
        # remove duplicate entries
        unique_data = list(set(data))
        logger.debug('Finished remove_duplicates function successfully')
        return unique_data
    except Exception as e:
        logger.error(f'Error in remove_duplicates function: {e}')
        raise



# and add more according to Python data cleaning steps
