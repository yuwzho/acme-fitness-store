package com.example.acme.assist;

import com.example.acme.assist.model.SuggestedPrompts;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SuggestedPromptService {

    @Autowired
    private SuggestedPromptRepository repository;

    /**
     * Returns suggested prompts according to specified page name.
     *
     * @param page
     * @return
     */
    public SuggestedPrompts getSuggestedPrompts(String page) {
        SuggestedPrompts prompts = repository.getSuggestedPrompts(page);
        return prompts == null ? repository.getDefaultSuggestedPrompts() : prompts;
    }
}
